.PHONY: bootstrap build test lint format format-check quality archive validate-release

PROJECT := MarvelChallenge.xcodeproj
SCHEME := MarvelChallenge
DESTINATION := platform=iOS Simulator,name=iPhone 16 Pro,arch=arm64
ARCHIVE_PATH ?= /tmp/MarvelChallenge-2.0.0.xcarchive
RELEASE_DERIVED_DATA ?= /tmp/MarvelChallengeReleaseDerived

bootstrap:
	mint bootstrap

build:
	xcodebuild build -project $(PROJECT) -scheme $(SCHEME) -destination '$(DESTINATION)' CODE_SIGNING_ALLOWED=NO

test:
	xcodebuild test -project $(PROJECT) -scheme $(SCHEME) -destination '$(DESTINATION)' -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO

lint:
	mint run swiftlint lint --strict

format:
	mint run swiftformat .

format-check:
	mint run swiftformat . --lint

quality: format-check lint

archive:
	xcodebuild archive -project $(PROJECT) -scheme $(SCHEME) -configuration Release -destination 'generic/platform=iOS' -archivePath '$(ARCHIVE_PATH)' -derivedDataPath '$(RELEASE_DERIVED_DATA)' CODE_SIGNING_ALLOWED=NO COMPILER_INDEX_STORE_ENABLE=NO

validate-release:
	./Scripts/validate-release.sh '$(ARCHIVE_PATH)'
