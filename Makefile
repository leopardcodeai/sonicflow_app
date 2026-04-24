.PHONY: help chrome safari ios mac mac-smoke android web web-dev test test-core-js test-core-swift test-chrome test-web test-android test-ios verify clean-dist chrome-build-assets

CHROME_DIR := sonicflow_app/chrome-extension
SAFARI_PROJECT := sonicflow_app/safari-extension/FlowTones/FlowTones.xcodeproj
IOS_PROJECT := sonicflow_app/ios-app/FlowTones.xcodeproj
DIST_CHROME := dist/chrome
ANDROID_APP_DIR := sonicflow_app/android-app
CORE_JS_DIR := sonicflow_app/core-js
CORE_SWIFT_DIR := sonicflow_app/core-swift
WEB_APP_DIR := sonicflow_app/web-app

help:
	@echo "SonicFlow monorepo targets:"
	@echo "  make chrome          Build Chrome extension and copy unpacked output to dist/chrome"
	@echo "  make safari          Open Safari extension Xcode project"
	@echo "  make ios             Build iOS app for simulator"
	@echo "  make mac             Build macOS app target"
	@echo "  make mac-smoke       Build and launch the macOS menu-bar app"
	@echo "  make android         Build Android debug APK"
	@echo "  make web            Run web app tests"
	@echo "  make web-dev        Start the local SonicFlow web app server"
	@echo "  make test            Run focused test suites across configured platforms"
	@echo "  make test-core-js    Run JS core tests"
	@echo "  make test-core-swift Run Swift core tests"
	@echo "  make test-chrome     Run Chrome extension tests"
	@echo "  make test-web        Run web app tests"
	@echo "  make test-android    Run Android unit tests when SDK/Java are configured"
	@echo "  make test-ios        Run iOS app tests when a simulator is available"
	@echo "  make verify          Run warning audit across supported platforms"
	@echo "  make clean-dist      Remove dist artifacts"

chrome-build-assets:
	cd $(CHROME_DIR) && npm ci
	cd $(CHROME_DIR) && npx esbuild content_script.js --bundle --outfile=dist/content_script.js

chrome: chrome-build-assets
	$(MAKE) clean-dist
	mkdir -p $(DIST_CHROME)
	rsync -a --delete --exclude node_modules --exclude package-lock.json --exclude '*.test.js' $(CHROME_DIR)/ $(DIST_CHROME)/

safari:
	open -a Xcode $(SAFARI_PROJECT)

ios:
	xcodebuild -project $(IOS_PROJECT) -scheme FlowTones -configuration Debug -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build

mac: chrome-build-assets
	xcodebuild -project $(SAFARI_PROJECT) -scheme 'FlowTones (macOS)' -configuration Debug -sdk macosx CODE_SIGNING_ALLOWED=NO build

mac-smoke:
	./scripts/mac_smoke.sh

android:
	@if [ -x $(ANDROID_APP_DIR)/gradlew ]; then \
		cd $(ANDROID_APP_DIR) && ./gradlew assembleDebug; \
	elif [ -x sonicflow_app/core-android/beatengine/gradlew ]; then \
		cd sonicflow_app/core-android/beatengine && ./gradlew assembleDebug; \
	else \
		echo 'No ./gradlew found in android-app or core-android/beatengine.'; \
		echo 'Android app module is pending (SF-12/SF-13).'; \
		exit 1; \
	fi

web: test-web

web-dev:
	npm --prefix $(WEB_APP_DIR) run dev

test-core-js:
	npm --prefix $(CORE_JS_DIR) test

test-core-swift:
	swift test --package-path $(CORE_SWIFT_DIR)

test-chrome:
	cd $(CHROME_DIR) && npm ci && npm test

test-web:
	npm --prefix $(WEB_APP_DIR) test

test-android:
	@if [ -x $(ANDROID_APP_DIR)/gradlew ] && { [ -n "$${ANDROID_HOME:-$${ANDROID_SDK_ROOT:-}}" ] || [ -f $(ANDROID_APP_DIR)/local.properties ]; } && command -v java >/dev/null 2>&1; then \
		cd $(ANDROID_APP_DIR) && ./gradlew testDebugUnitTest; \
	else \
		echo 'Skipping Android unit tests because Android SDK/Java are not configured.'; \
	fi

test-ios:
	./scripts/check_warnings.sh --ios-tests

test: test-core-js test-core-swift test-chrome test-web test-android test-ios

verify:
	./scripts/check_warnings.sh

clean-dist:
	rm -rf dist
