phantom-express
===============

phantom-express middleware allows for dynamically created content to be visible to Google crawler.
This middleware tests the request for an ```_escaped_fragment_``` query parameter. If the parameter is detected the middleware passes pretty URL to the phantomjs process.

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
    Warning: ```apt-get``` is having an issue installing recent version of phantomjs. Avoid using ```apt-get install``` phantomjs

2. Add middleware to the express

	```javascript
	var phantomExpress = require("phantom-express");

	app.use(express.query())
	app.use(phantomExpress(options));
	```

Default options:
```javascript
options = {
    // Currently the middleware caches the response from the
    // phantomjs process in the memory. The parameter defines
    // TTL in seconds. If 0 is passed the cache will be ignored.
    cacheLifetime: 3600*1000

    // Dump status to the console or not
    verbose: false

    // Prepends the string to the pretty generated hash
    // ex. if '!' is defined ->  #!/home/page
    hashPrepend: ''
}
```



### How it works?


The middleware detects if the request URL contains ```_escaped_fragment_``` (ex. ```http://mysite.com/some/path?_escaped_fragment_=hello/world```) query parameter. If so, it parses the request url, generates pretty URL with hash fragment (ex. ```http://mysite.com/some/path#hello/world```) and passes it to the phantomjs proccess.

Step by step process:
* The phantomjs proccess renders the page
* Evaluates javascript code
* Waits 5 seconds after last resource has been received (useful for requirejs)
* Grabs the generated HTML
* Sends it to the Google crawler

More information at: https://developers.google.com/webmasters/ajax-crawling/docs/specification