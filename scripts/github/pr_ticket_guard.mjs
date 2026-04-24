#!/usr/bin/env node

import { fileURLToPath } from "node:url";

const BRANCH_PATTERN = /^(?:feature\/([A-Z]+-\d+)|codex\/([a-z]+-\d+))-[a-z0-9._-]+$/i;
const TITLE_PATTERN = /^\[([A-Z]+-\d+)\]\s+.+/;

export function validatePullRequest({ branch = "", title = "", body = "" }) {
  const errors = [];
  const branchMatch = branch.match(BRANCH_PATTERN);
  const titleMatch = title.match(TITLE_PATTERN);

  if (!branchMatch) {
    errors.push(
      "Branch muss dem Format `feature/TICKET-ID-desc` oder `codex/ticket-id-desc` entsprechen, z. B. `feature/SF-21-workflow` oder `codex/sf-21-workflow`."
    );
  }

  if (!titleMatch) {
    errors.push(
      "PR-Titel muss mit `[TICKET-ID]` starten, z. B. `[SF-21] Implement workflow guards`."
    );
  }

  const branchTicket = branchMatch ? (branchMatch[1] || branchMatch[2]).toUpperCase() : null;
  const titleTicket = titleMatch ? titleMatch[1].toUpperCase() : null;

  if (branchTicket && titleTicket && branchTicket !== titleTicket) {
    errors.push(
      `Ticket-ID mismatch: Branch hat \`${branchTicket}\`, Titel hat \`${titleTicket}\`.`
    );
  }

  const requiredTicket = titleTicket || branchTicket;
  if (!requiredTicket) {
    errors.push("Konnte keine Ticket-ID aus Branch oder Titel extrahieren.");
  } else if (!body.includes(requiredTicket)) {
    errors.push(
      `PR-Body muss die Ticket-ID \`${requiredTicket}\` enthalten (Linear-Link oder \`Linear: ${requiredTicket}\`).`
    );
  }

  if (requiredTicket && !hasLinearReference(body, requiredTicket)) {
    errors.push(
      `PR-Body muss einen Linear-Verweis auf \`${requiredTicket}\` enthalten (Linear-Link oder \`Linear: ${requiredTicket}\`).`
    );
  }

  return {
    ticket: requiredTicket,
    errors
  };
}

function hasLinearReference(body, ticket) {
  const linearUrlContainsTicket = new RegExp(
    `linear\\.app\\/[^\\s)]*${ticket}`,
    "i"
  ).test(body);
  const linearShorthandContainsTicket = new RegExp(
    `(?:^|\\n)\\s*Linear\\s*:\\s*${ticket}\\b`,
    "i"
  ).test(body);

  return linearUrlContainsTicket || linearShorthandContainsTicket;
}

function runFromEnvironment() {
  const result = validatePullRequest({
    branch: process.env.PR_BRANCH ?? "",
    title: process.env.PR_TITLE ?? "",
    body: process.env.PR_BODY ?? ""
  });

  if (result.errors.length > 0) {
    console.error(result.errors.join("\n"));
    process.exitCode = 1;
    return;
  }

  console.log(`PR-Guard erfolgreich: ${result.ticket}`);
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  runFromEnvironment();
}
