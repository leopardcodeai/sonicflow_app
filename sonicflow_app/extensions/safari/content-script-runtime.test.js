import test from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";

import {
  createChunkPlan,
  DEFAULT_ENGINE_SETTINGS,
  detectPageContext
} from "./content-script-runtime.js";

const manifest = JSON.parse(
  readFileSync(new URL("./manifest.json", import.meta.url), "utf8")
);
const packageJson = JSON.parse(
  readFileSync(new URL("./package.json", import.meta.url), "utf8")
);

test("runtime exposes the default chunk scheduling settings", () => {
  assert.equal(DEFAULT_ENGINE_SETTINGS.chunkDurationSeconds, 10);
  assert.equal(DEFAULT_ENGINE_SETTINGS.overlapSeconds, 1);
});

test("createChunkPlan schedules the next chunk before the current chunk ends", () => {
  const plan = createChunkPlan({
    startedAt: 12,
    chunkDurationSeconds: 10,
    overlapSeconds: 1
  });

  assert.equal(plan.current.endsAt, 22);
  assert.equal(plan.next.startsAt, 21);
  assert.equal(plan.next.endsAt, 31);
});

test("manifest and package scripts point at the bundled content script", () => {
  assert.equal(manifest.content_scripts[0].js[0], "dist/content_script.js");
  assert.match(packageJson.scripts.build, /esbuild/);
  assert.match(packageJson.scripts.watch, /--watch/);
});

test("detectPageContext identifies writing surfaces from page signals", () => {
  const context = detectPageContext({
    url: "https://docs.google.com/document/d/123/edit",
    title: "Launch plan",
    hasEditableText: true,
    pageHasAudioSource: false
  });

  assert.deepEqual(context, {
    id: "writing-doc",
    label: "Writing Doc",
    host: "docs.google.com",
    suggestedActivityId: "deep-work",
    suggestedMode: "focus",
    pageHasAudioSource: false,
    mediaService: null
  });
});

test("detectPageContext identifies media services and keeps audio availability real", () => {
  const context = detectPageContext({
    url: "https://www.youtube.com/watch?v=abc",
    title: "Live set",
    hasEditableText: false,
    pageHasAudioSource: true
  });

  assert.equal(context.id, "youtube-media");
  assert.equal(context.label, "YouTube");
  assert.equal(context.suggestedActivityId, "creative-flow");
  assert.equal(context.pageHasAudioSource, true);
  assert.equal(context.mediaService, "youtube");
});
