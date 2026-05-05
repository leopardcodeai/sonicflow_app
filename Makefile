.PHONY: help safari-web-extension safari ios mac mac-smoke web web-dev xcodegen test test-core-js test-core-swift test-safari-web-extension test-web test-web-e2e test-github-workflows test-ios test-ios-ui verify clean-dist safari-web-assets safari-web-extension-build-assets

WEB_EXTENSION_DIR := sonicflow_app/extensions/safari
MACOS_PROJECT := sonicflow_app/apps/macos/SonicFlow.xcodeproj
IOS_PROJECT := sonicflow_app/apps/ios/SonicFlow.xcodeproj
DIST_SAFARI_WEB_EXTENSION := dist/safari-web-extension
CORE_JS_DIR := sonicflow_app/shared/core-js
CORE_SWIFT_DIR := sonicflow_app/shared/core-swift
WEB_APP_DIR := sonicflow_app/apps/web
XCODE_WARNING_CLEAN_SETTINGS := CODE_SIGNING_ALLOWED=NO ENABLE_APP_INTENTS_METADATA_GENERATION=NO EXTRACT_APP_INTENTS_METADATA=NO OTHER_LDFLAGS="-framework AppIntents"

help:
	@echo "SonicFlow monorepo targets:"
	@echo "  make safari-web-extension          Build Safari Web Extension and copy unpacked output to dist/safari-web-extension"
	@echo "  make safari-web-assets Build Safari Web Extension JavaScript assets"
	@echo "  make safari          Open Safari extension Xcode project"
	@echo "  make ios             Build iOS app for simulator"
	@echo "  make mac             Build macOS app target"
	@echo "  make mac-smoke       Build and launch the macOS menu-bar app"
	@echo "  make web             Run web app tests"
	@echo "  make web-dev         Start the local SonicFlow web app server"
	@echo "  make test            Run focused tests for active Apple/Safari/web platforms"
	@echo "  make test-core-js    Run JS core tests"
	@echo "  make test-core-swift Run Swift core tests"
	@echo "  make test-safari-web-extension Run Safari Web Extension resource tests"
	@echo "  make test-web        Run web app unit tests"
	@echo "  make test-web-e2e    Run web app E2E tests (Playwright)"
	@echo "  make test-github-workflows Run GitHub workflow guard tests"
	@echo "  make test-ios        Run iOS app tests when a simulator is available"
	@echo "  make test-ios-ui     Run iOS UI tests when a simulator is available"
	@echo "  make xcodegen        Regenerate iOS Xcode project from project.yml"
	@echo "  make verify          Run warning audit for active Apple/Safari/web platforms"
	@echo "  make clean-dist      Remove dist artifacts"

safari-web-extension-build-assets:
	cd $(WEB_EXTENSION_DIR) && npm ci
	cd $(WEB_EXTENSION_DIR) && npm run build

safari-web-assets: safari-web-extension-build-assets

safari-web-extension: safari-web-extension-build-assets
	$(MAKE) clean-dist
	mkdir -p $(DIST_SAFARI_WEB_EXTENSION)
	rsync -a --delete --exclude node_modules --exclude package-lock.json --exclude '*.test.js' $(WEB_EXTENSION_DIR)/ $(DIST_SAFARI_WEB_EXTENSION)/

safari:
	open -a Xcode $(MACOS_PROJECT)

ios:
	xcodebuild -project $(IOS_PROJECT) -scheme SonicFlow -configuration Debug -destination 'generic/platform=iOS Simulator' $(XCODE_WARNING_CLEAN_SETTINGS) build

mac: safari-web-assets
	xcodebuild -project $(MACOS_PROJECT) -scheme 'SonicFlow (macOS)' -configuration Debug -destination 'platform=macOS,arch=arm64' $(XCODE_WARNING_CLEAN_SETTINGS) build

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
	cd $(WEB_EXTENSION_DIR) && npm ci && npm test

test-web:
	npm --prefix $(WEB_APP_DIR) test

test-web-e2e:
	npm --prefix $(WEB_APP_DIR) run test:e2e

test-ios-ui:
	xcodebuild -project $(IOS_PROJECT) -scheme SonicFlow -destination 'platform=iOS Simulator,name=iPhone 16' $(XCODE_WARNING_CLEAN_SETTINGS) -only-testing:SonicFlowUITests test

xcodegen:
	xcodegen generate --spec sonicflow_app/apps/ios/project.yml --project sonicflow_app/apps/ios/

test-github-workflows:
	node --test scripts/github/*.test.mjs

test-ios:
	./scripts/check_warnings.sh --ios-tests

test: test-core-js test-core-swift test-safari-web-extension test-web test-github-workflows test-ios

verify:
	./scripts/check_warnings.sh

clean-dist:
	rm -rf dist
