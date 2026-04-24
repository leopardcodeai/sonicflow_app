import test from "node:test";
import assert from "node:assert/strict";

import { validatePullRequest } from "./pr_ticket_guard.mjs";

test("accepts Codex branch with matching title and Linear shorthand", () => {
  const result = validatePullRequest({
    branch: "codex/sf-42-fix-github-checks",
    title: "[SF-42] Fix GitHub checks",
    body: "## Summary\n- Fix checks\n\nLinear: SF-42"
  });

  assert.equal(result.ticket, "SF-42");
  assert.deepEqual(result.errors, []);
});

test("accepts feature branch with matching Linear URL", () => {
  const result = validatePullRequest({
    branch: "feature/SF-42-workflow-guard",
    title: "[SF-42] Fix workflow guard",
    body: "Linear: https://linear.app/captain-leopard-ai-engineering/issue/SF-42/fix-github-checks"
  });

  assert.equal(result.ticket, "SF-42");
  assert.deepEqual(result.errors, []);
});

test("rejects missing branch ticket", () => {
  const result = validatePullRequest({
    branch: "main",
    title: "[SF-42] Fix GitHub checks",
    body: "Linear: SF-42"
  });

  assert.equal(result.ticket, "SF-42");
  assert.match(result.errors.join("\n"), /Branch muss/);
});

test("rejects mismatched branch and title tickets", () => {
  const result = validatePullRequest({
    branch: "codex/sf-42-fix-github-checks",
    title: "[SF-99] Fix GitHub checks",
    body: "Linear: SF-99"
  });

  assert.match(result.errors.join("\n"), /Ticket-ID mismatch/);
});

test("rejects a PR body without Linear reference", () => {
  const result = validatePullRequest({
    branch: "codex/sf-42-fix-github-checks",
    title: "[SF-42] Fix GitHub checks",
    body: "No ticket here"
  });

  assert.match(result.errors.join("\n"), /Linear/);
});
