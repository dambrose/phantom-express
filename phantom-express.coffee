_ = require 'lodash'
child_process = require 'child_process'
cache = require './memory-cache'


module.exports = middleware = (options) ->
  options = _.assign({
    cacheLifetime: 3600
    verbose: false
    hashPrepend: ''
  }, options)

  (req, res, next) ->

    # Ignore the phantom process if escaped fragment is not defined
    return next() if !_.has(req.query, '_escaped_fragment_') # || !~req.headers.accept.indexOf('text/html')


    # Parse url request
    url = req.url.split('?')[0]
    queryParams = _.clone(req.query);

    fragment = "##{options.hashPrepend}#{queryParams['_escaped_fragment_']}"
    delete queryParams['_escaped_fragment_']
    queryParams = _.map queryParams, (item, key) -> "#{key}=#{item}"
    queryParams = if queryParams.length then "?#{queryParams.join('&')}" else ''

    # Generate url to the server
    fullUrl = [req.protocol, '://', req.get('host'), url, queryParams, fragment].join('')

    # Read from cache
    if (options.cacheLifetime and data = cache.get(fullUrl))
      console.log("Phantom: cache, from url %s", fullUrl) if options.verbose
      return res.send(200, data)

    console.log('Phantom: processing page %s, from url %s', fullUrl, req.url) if options.verbose

    # Render the page
    child_process.exec "phantomjs --load-images=no #{__dirname}/render.js '#{fullUrl}'", (error, stdout, stderr) ->
      cache.set(fullUrl, stdout, options.cacheLifetime * 1000) if not error and not stderr and options.cacheLifetime

      res.send.apply(res, (if error || stderr then [500, error || stderr] else [200, stdout]))

      if options.verbose
        console.log("Phantom: error occured generating %s\n%s", fullUrl, error) if error
        console.log("Phantom: stderror occured generating %s\n%s", fullUrl, stderr) if stderr
        console.log("Phantom: OK %s", fullUrl) if stdout && !(error || stderr)


middleware.middlewarePriority = -2