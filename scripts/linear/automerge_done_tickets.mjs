#!/usr/bin/env node

const LINEAR_API_TOKEN = process.env.LINEAR_API_TOKEN;
const GITHUB_TOKEN = process.env.GITHUB_TOKEN;
const REPOSITORY = process.env.GITHUB_REPOSITORY;

if (!LINEAR_API_TOKEN || !GITHUB_TOKEN || !REPOSITORY) {
  console.log("Fehlende Tokens/Repository-Kontext. Überspringe Auto-Merge.");
  process.exit(0);
}

const [owner, repo] = REPOSITORY.split("/");

function extractTicketKey(pr) {
  const fields = [pr.title || "", pr.body || "", pr.head?.ref || ""];
  for (const field of fields) {
    const match = field.match(/[A-Z]+-\d+/);
    if (match) return match[0];
  }
  return null;
}

async function linearGraphQL(query, variables = {}) {
  const response = await fetch("https://api.linear.app/graphql", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: LINEAR_API_TOKEN
    },
    body: JSON.stringify({ query, variables })
  });

  if (!response.ok) {
    throw new Error(`Linear API HTTP ${response.status}`);
  }

  const payload = await response.json();
  if (payload.errors?.length) {
    throw new Error(`Linear GraphQL Fehler: ${JSON.stringify(payload.errors)}`);
  }

  return payload.data;
}

async function githubApi(path, options = {}) {
  const response = await fetch(`https://api.github.com${path}`, {
    ...options,
    headers: {
      Accept: "application/vnd.github+json",
      Authorization: `Bearer ${GITHUB_TOKEN}`,
      "X-GitHub-Api-Version": "2022-11-28",
      ...(options.headers || {})
    }
  });
  return response;
}

async function getIssueState(ticketKey) {
  const byIdQuery = `
    query($ticketKey: String!) {
      issue(id: $ticketKey) {
        state {
          name
          type
        }
      }
    }
  `;

  const fallbackQuery = `
    query($ticketKey: String!) {
      issues(filter: { identifier: { eq: $ticketKey } }, first: 1) {
        nodes {
          state {
            name
            type
          }
        }
      }
    }
  `;

  try {
    const direct = await linearGraphQL(byIdQuery, { ticketKey });
    if (direct.issue?.state) return direct.issue.state;
  } catch (error) {
    console.log(`Direkter Issue-Lookup fehlgeschlagen, fallback aktiv: ${error.message}`);
  }

  const fallback = await linearGraphQL(fallbackQuery, { ticketKey });
  return fallback.issues?.nodes?.[0]?.state || null;
}

async function listOpenPullRequests() {
  const all = [];
  let page = 1;

  while (true) {
    const response = await githubApi(
      `/repos/${owner}/${repo}/pulls?state=open&per_page=100&page=${page}`
    );
    if (!response.ok) {
      throw new Error(`GitHub PR-List fehlgeschlagen: HTTP ${response.status}`);
    }

    const chunk = await response.json();
    all.push(...chunk);

    if (chunk.length < 100) break;
    page += 1;
  }

  return all;
}

async function mergePullRequest(number) {
  const response = await githubApi(`/repos/${owner}/${repo}/pulls/${number}/merge`, {
    method: "PUT",
    body: JSON.stringify({
      merge_method: "squash"
    })
  });

  if (response.status === 200) {
    return { merged: true, message: "merged" };
  }

  const body = await response.text();
  return { merged: false, message: `HTTP ${response.status}: ${body}` };
}

async function main() {
  const prs = await listOpenPullRequests();
  console.log(`Prüfe ${prs.length} offene PRs auf Done-Tickets.`);

  for (const pr of prs) {
    if (pr.draft) {
      console.log(`#${pr.number}: draft -> skip`);
      continue;
    }

    const ticketKey = extractTicketKey(pr);
    if (!ticketKey) {
      console.log(`#${pr.number}: kein Ticket-Key -> skip`);
      continue;
    }

    const state = await getIssueState(ticketKey);
    if (!state) {
      console.log(`#${pr.number}: Ticket ${ticketKey} nicht gefunden -> skip`);
      continue;
    }

    const isDone = state.type === "completed" || state.name.toLowerCase() === "done";
    if (!isDone) {
      console.log(`#${pr.number}: ${ticketKey} ist ${state.name} -> skip`);
      continue;
    }

    const result = await mergePullRequest(pr.number);
    if (result.merged) {
      console.log(`#${pr.number}: ${ticketKey} ist Done -> PR gemerged`);
    } else {
      console.log(`#${pr.number}: Merge für ${ticketKey} fehlgeschlagen: ${result.message}`);
    }
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
