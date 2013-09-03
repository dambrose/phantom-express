// Generated by CoffeeScript 1.6.3
(function() {
  var cache, child_process, middleware, _;

  _ = require('lodash');

  child_process = require('child_process');

  cache = require('memory-cache');

  module.exports = middleware = function(options) {
    options = _.assign({
      cacheLifetime: 3600,
      verbose: false,
      hashPrepend: ''
    }, options);
    return function(req, res, next) {
      var data, fragment, fullUrl, queryParams, url;
      if (!_.has(req.query, '_escaped_fragment_')) {
        return next();
      }
      url = req.url.split('?')[0];
      queryParams = _.clone(req.query);
      fragment = "#" + options.hashPrepend + queryParams['_escaped_fragment_'];
      delete queryParams['_escaped_fragment_'];
      queryParams = _.map(queryParams, function(item, key) {
        return "" + key + "=" + item;
      });
      queryParams = queryParams.length ? "?" + (queryParams.join('&')) : '';
      fullUrl = [req.protocol, '://', req.get('host'), url, queryParams, fragment].join('');
      if (options.cacheLifetime && (data = cache.get(fullUrl))) {
        if (options.verbose) {
          console.log("Phantom: cache, from url %s", fullUrl);
        }
        return res.send(200, data);
      }
      if (options.verbose) {
        console.log('Phantom: processing page %s, from url %s', fullUrl, req.url);
      }
      return child_process.exec("phantomjs --load-images=no " + __dirname + "/render.js '" + fullUrl + "'", function(error, stdout, stderr) {
        if (!error && !stderr && options.cacheLifetime) {
          cache.set(fullUrl, stdout, options.cacheLifetime * 1000);
        }
        res.send.apply(res, (error || stderr ? [500, error || stderr] : [200, stdout]));
        if (options.verbose) {
          if (error) {
            console.log("Phantom: error occured generating %s\n%s", fullUrl, error);
          }
          if (stderr) {
            console.log("Phantom: stderror occured generating %s\n%s", fullUrl, stderr);
          }
          if (stdout && !(error || stderr)) {
            return console.log("Phantom: OK %s", fullUrl);
          }
        }
      });
    };
  };

  middleware.middlewarePriority = -2;

}).call(this);
