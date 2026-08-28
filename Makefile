.PHONY: bootstrap build test lint format format-check quality

PROJECT := MarvelChallenge.xcodeproj
SCHEME := MarvelChallenge
DESTINATION := platform=iOS Simulator,name=iPhone 16 Pro,arch=arm64

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
