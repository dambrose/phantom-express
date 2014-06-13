_ = require 'lodash'
child_process = require 'child_process'
redis = require 'redis'



module.exports = middleware = (options) ->
  options = _.assign({
    cacheLifetime: 600
    store: null
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

    # Render the page
    processDo = (cb) ->
      child_process.exec "phantomjs --load-images=no #{__dirname}/render.js '#{fullUrl}'", (error, stdout, stderr) ->
        if error or stderr
          res.send 500, error || stderr
        else
          cb(stdout) if _.isFunction(cb)
          res.send 200, stdout

    # Cache
    if options.store && options.store.ready
      cacheName = 'phantom-' + fullUrl
      options.store.get cacheName, (err, result) ->
        if result
          res.send 200, result
        else
          processDo (data) ->
            options.store.set cacheName, data
            options.store.expire cacheName, options.cacheLifetime
    else
      processDo()

middleware.middlewarePriority = -2