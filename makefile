all: clean dist

dist:
	node_modules/.bin/coffee --output dist/scripts --compile app/scripts/contentscript.coffee
	cp -R app/_locales dist
	cp app/manifest.json dist

clean:
	rm -rf dist

.PHONY: all dist clean
