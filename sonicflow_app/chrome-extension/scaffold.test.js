import test from "node:test";
import assert from "node:assert/strict";
import { readFileSync, existsSync } from "node:fs";
import { join } from "node:path";

const root = new URL(".", import.meta.url);
const manifest = JSON.parse(
  readFileSync(new URL("./manifest.json", root), "utf8")
);

test("manifest declares the expected MV3 basics", () => {
  assert.equal(manifest.manifest_version, 3);
  assert.equal(manifest.name, "FlowTones");
  assert.deepEqual(manifest.permissions, ["storage", "activeTab", "scripting"]);
  assert.deepEqual(manifest.host_permissions, [
    "*://*.youtube.com/*",
    "*://*.soundcloud.com/*"
  ]);
  assert.equal(manifest.background.service_worker, "background.js");
  assert.equal(manifest.action.default_popup, "popup.html");
  assert.equal(manifest.content_scripts[0].js[0], "dist/content_script.js");
});

test("scaffold files exist", () => {
  const expectedFiles = [
    "content_script.js",
    "browser-polyfill.js",
    "content-script-runtime.js",
    "background.js",
    "popup.html",
    "popup.js",
    "icons/icon-16.svg",
    "icons/icon-32.svg",
    "icons/icon-48.svg",
    "icons/icon-128.svg"
  ];

  for (const relativePath of expectedFiles) {
    assert.equal(existsSync(join(root.pathname, relativePath)), true, relativePath);
  }
});
