.PHONY: help safari-web-extension safari ios mac mac-smoke web web-dev test test-core-js test-core-swift test-safari-web-extension test-web test-github-workflows test-ios verify clean-dist safari-web-extension-build-assets

SAFARI_WEB_EXTENSION_DIR := sonicflow_app/safari-web-extension
SAFARI_PROJECT := sonicflow_app/safari-extension/SonicFlow/SonicFlow.xcodeproj
IOS_PROJECT := sonicflow_app/ios-app/SonicFlow.xcodeproj
DIST_SAFARI_WEB_EXTENSION := dist/safari-web-extension
CORE_JS_DIR := sonicflow_app/core-js
CORE_SWIFT_DIR := sonicflow_app/core-swift
WEB_APP_DIR := sonicflow_app/web-app

help:
	@echo "SonicFlow monorepo targets:"
	@echo "  make safari-web-extension          Build Safari web extension and copy unpacked output to dist/safari-web-extension"
	@echo "  make safari          Open Safari extension Xcode project"
	@echo "  make ios             Build iOS app for simulator"
	@echo "  make mac             Build macOS app target"
	@echo "  make mac-smoke       Build and launch the macOS menu-bar app"
	@echo "  make web            Run web app tests"
	@echo "  make web-dev        Start the local SonicFlow web app server"
	@echo "  make test            Run focused test suites across configured platforms"
	@echo "  make test-core-js    Run JS core tests"
	@echo "  make test-core-swift Run Swift core tests"
	@echo "  make test-safari-web-extension     Run Safari web extension tests"
	@echo "  make test-web        Run web app tests"
	@echo "  make test-github-workflows Run GitHub workflow guard tests"
	@echo "  make test-ios        Run iOS app tests when a simulator is available"
	@echo "  make verify          Run warning audit across supported platforms"
	@echo "  make clean-dist      Remove dist artifacts"

safari-web-extension-build-assets:
	cd $(SAFARI_WEB_EXTENSION_DIR) && npm ci
	cd $(SAFARI_WEB_EXTENSION_DIR) && npx esbuild content_script.js --bundle --outfile=dist/content_script.js

safari-web-extension: safari-web-extension-build-assets
	$(MAKE) clean-dist
	mkdir -p $(DIST_SAFARI_WEB_EXTENSION)
	rsync -a --delete --exclude node_modules --exclude package-lock.json --exclude '*.test.js' $(SAFARI_WEB_EXTENSION_DIR)/ $(DIST_SAFARI_WEB_EXTENSION)/

safari:
	open -a Xcode $(SAFARI_PROJECT)

ios:
	xcodebuild -project $(IOS_PROJECT) -scheme SonicFlow -configuration Debug -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build

mac: safari-web-extension-build-assets
	xcodebuild -project $(SAFARI_PROJECT) -scheme 'SonicFlow (macOS)' -configuration Debug -sdk macosx CODE_SIGNING_ALLOWED=NO build

mac-smoke:
	./scripts/mac_smoke.sh

web: test-web

web-dev:
	npm --prefix $(WEB_APP_DIR) run dev

test-core-js:
	npm --prefix $(CORE_JS_DIR) test

test-core-swift:
	swift test --package-path $(CORE_SWIFT_DIR)

test-safari-web-extension:
	cd $(SAFARI_WEB_EXTENSION_DIR) && npm ci && npm test

test-web:
	npm --prefix $(WEB_APP_DIR) test

test-github-workflows:
	node --test scripts/github/*.test.mjs

test-ios:
	./scripts/check_warnings.sh --ios-tests

test: test-core-js test-core-swift test-safari-web-extension test-web test-github-workflows test-ios

verify:
	./scripts/check_warnings.sh

clean-dist:
	rm -rf dist
