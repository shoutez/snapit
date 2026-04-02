.PHONY: build bundle install run clean

build:
	swift build -c release

bundle: build
	bash scripts/bundle.sh

install: bundle
	cp -R SnapIt.app /Applications/
	@echo "Installed SnapIt.app to /Applications"

run: bundle
	open SnapIt.app

clean:
	swift package clean
	rm -rf SnapIt.app
