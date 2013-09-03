express-phantom
===============

express-phantom middleware tests the request for a Google's _escaped_fragment_ query parameter. If the parameter is detected the middleware passes request to the phantomjs process.

1. Install phantomjs

	On mac:
	```sh
	brew install phantomjs 
	```

	On Ubuntu:
	```sh
	sudo apt-get update
	sudo apt-get install build-essential chrpath git-core libssl-dev libfontconfig1-dev
	git clone git://github.com/ariya/phantomjs.git
	cd phantomjs
	git checkout 1.9
	./build.sh
```
    Warning: apt-get is having an issue installing recent version of phantomjs.

2. Add middleware to the express

	```javascript
	var phantomExpress = require("phantom-express");

	app.use(express.query())
	app.use(expressPhantom(options));
	```

Default options:
```javascript
options = {
    cacheLifetime: 3600*1000
    verbose: false
    hashPrepend: ''
}
```