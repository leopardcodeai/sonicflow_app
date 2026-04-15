.PHONY: chrome safari ios mac android

CHROME_DIR := sonicflow_app/chrome-extension
SAFARI_PROJECT := sonicflow_app/safari-extension/FlowTones/FlowTones.xcodeproj
IOS_PROJECT := sonicflow_app/ios-app/FlowTones.xcodeproj
DIST_CHROME := dist/chrome

chrome:
	cd $(CHROME_DIR) && npm ci
	cd $(CHROME_DIR) && npm run build
	rm -rf $(DIST_CHROME)
	mkdir -p $(DIST_CHROME)
	rsync -a --delete --exclude node_modules --exclude package-lock.json --exclude '*.test.js' $(CHROME_DIR)/ $(DIST_CHROME)/

safari:
	open -a Xcode $(SAFARI_PROJECT)

ios:
	xcodebuild -project $(IOS_PROJECT) -scheme FlowTones -configuration Debug -destination 'generic/platform=iOS Simulator' build

mac:
	xcodebuild -project $(SAFARI_PROJECT) -scheme 'FlowTones (macOS)' -configuration Debug -sdk macosx CODE_SIGNING_ALLOWED=NO build

android:
	@if [ -x sonicflow_app/android-app/gradlew ]; then \
		cd sonicflow_app/android-app && ./gradlew assembleDebug; \
	elif [ -x sonicflow_app/core-android/beatengine/gradlew ]; then \
		cd sonicflow_app/core-android/beatengine && ./gradlew assembleDebug; \
	else \
		echo 'No ./gradlew found in android-app or core-android/beatengine.'; \
		echo 'Android app module is pending (SF-12/SF-13).'; \
		exit 1; \
	fi
