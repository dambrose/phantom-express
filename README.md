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
	sudo apt-get install phantomjs
```
    Note: apt-get is having an issue installing recent version of phantomjs.

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
}
```