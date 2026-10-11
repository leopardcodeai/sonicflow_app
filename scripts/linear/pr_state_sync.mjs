#!/usr/bin/env node

import fs from "node:fs";

const LINEAR_API_TOKEN = process.env.LINEAR_API_TOKEN;
const EVENT_PATH = process.env.GITHUB_EVENT_PATH;

if (!LINEAR_API_TOKEN) {
  console.log("LINEAR_API_TOKEN fehlt. Überspringe Linear Sync.");
  process.exit(0);
}

if (!EVENT_PATH || !fs.existsSync(EVENT_PATH)) {
  console.log("Kein GITHUB_EVENT_PATH gefunden. Überspringe.");
  process.exit(0);
}

const event = JSON.parse(fs.readFileSync(EVENT_PATH, "utf8"));
const action = event.action;
const pr = event.pull_request;

if (!pr) {
  console.log("Kein pull_request Event. Überspringe.");
  process.exit(0);
}

function extractTicketKeyFromText(text) {
  if (!text) return null;
  const match = text.match(/[A-Z]+-\d+/);
  return match ? match[0] : null;
}

function extractTicketKey(prObj) {
  const titleMatch = (prObj.title || "").match(/^\[([A-Z]+-\d+)\]/);
  if (titleMatch) return titleMatch[1];

  const branchMatch = (prObj.head?.ref || "").match(/^feature\/([A-Z]+-\d+)-/);
  if (branchMatch) return branchMatch[1];

  return extractTicketKeyFromText(prObj.body || "");
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

async function getIssueByTicketKey(ticketKey) {
  // Prefer direct lookup by issue key; fallback to identifier filter for compatibility.
  const byIdQuery = `
    query($ticketKey: String!) {
      issue(id: $ticketKey) {
        id
        identifier
        team {
          key
        }
        state {
          id
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
          id
          identifier
          team {
            key
          }
          state {
            id
            name
            type
          }
        }
      }
    }
  `;

  try {
    const direct = await linearGraphQL(byIdQuery, { ticketKey });
    if (direct.issue) return direct.issue;
  } catch (error) {
    console.log(`Direkter Issue-Lookup fehlgeschlagen, fallback aktiv: ${error.message}`);
  }

  const fallback = await linearGraphQL(fallbackQuery, { ticketKey });
  return fallback.issues?.nodes?.[0] || null;
}

async function getTeamStates(teamKey) {
  const query = `
    query($teamKey: String!) {
      teams(filter: { key: { eq: $teamKey } }, first: 1) {
        nodes {
          key
          states {
            nodes {
              id
              name
              type
            }
          }
        }
      }
    }
  `;

  const data = await linearGraphQL(query, { teamKey });
  const team = data.teams?.nodes?.[0];
  if (!team) return [];
  return team.states?.nodes || [];
}

function findState(states, preferredNames, fallbackType) {
  const normalizedNames = preferredNames.map((name) => name.toLowerCase());
  const byName = states.find((state) =>
    normalizedNames.includes(state.name.toLowerCase())
  );
  if (byName) return byName;
  if (!fallbackType) return null;
  return states.find((state) => state.type === fallbackType) || null;
}

async function updateIssueState(issueId, stateId) {
  const mutation = `
    mutation($issueId: String!, $stateId: String!) {
      issueUpdate(id: $issueId, input: { stateId: $stateId }) {
        success
      }
    }
  `;
  const data = await linearGraphQL(mutation, { issueId, stateId });
  return Boolean(data.issueUpdate?.success);
}

async function main() {
  const ticketKey = extractTicketKey(pr);
  if (!ticketKey) {
    console.log("Kein Ticket-Key im PR gefunden. Überspringe Linear Sync.");
    return;
  }

  const issue = await getIssueByTicketKey(ticketKey);
  if (!issue) {
    console.log(`Linear-Issue ${ticketKey} nicht gefunden. Überspringe.`);
    return;
  }

  const states = await getTeamStates(issue.team.key);
  if (states.length === 0) {
    console.log(`Keine States für Team ${issue.team.key} gefunden. Überspringe.`);
    return;
  }

  const inProgressState = findState(states, ["In Progress"], "started");
  const previewState = findState(states, ["Preview", "In Review"], "started");
  const doneState = findState(states, ["Done"], "completed");

  let targetState = null;

  if (["opened", "reopened", "synchronize"].includes(action)) {
    targetState = pr.draft ? inProgressState : previewState;
  } else if (action === "ready_for_review") {
    targetState = previewState;
  } else if (action === "converted_to_draft") {
    targetState = inProgressState;
  } else if (action === "closed" && pr.merged === true) {
    targetState = doneState;
  } else {
    console.log(`Aktion ${action} triggert keinen State-Wechsel.`);
    return;
  }

  if (!targetState) {
    console.log("Kein passender Ziel-State gefunden. Überspringe.");
    return;
  }

  const currentStateName = issue.state?.name?.toLowerCase() || "";
  if (currentStateName === "backlog" && action !== "closed") {
    throw new Error(
      `Issue ${ticketKey} ist noch in Backlog. Bitte zuerst manuell nach Todo verschieben.`
    );
  }

  if (issue.state?.id === targetState.id) {
    console.log(
      `Issue ${ticketKey} ist bereits in ${targetState.name}. Kein Update nötig.`
    );
    return;
  }

  const ok = await updateIssueState(issue.id, targetState.id);
  if (!ok) {
    throw new Error(`State-Update für ${ticketKey} fehlgeschlagen.`);
  }

  console.log(
    `Issue ${ticketKey} von ${issue.state?.name || "unknown"} -> ${targetState.name}`
  );
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
