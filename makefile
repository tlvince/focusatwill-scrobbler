all: clean dist

dist:
	node_modules/.bin/coffee --output dist/scripts --compile app/scripts/*
	cp -R app/_locales dist
	cp app/manifest.json dist
	mkdir -p dist/bower_components/spark-md5
	cp app/bower_components/spark-md5/spark-md5.min.js dist/bower_components/spark-md5

clean:
	rm -rf dist

.PHONY: all dist clean
