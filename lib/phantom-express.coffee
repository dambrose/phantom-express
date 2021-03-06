_ = require 'lodash'
child_process = require 'child_process'
redis = require 'redis'



module.exports = middleware = (options) ->
  options = _.assign({
    cacheLifetime: 0
    store: null,
    cachePrefix: 'phantom-',
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
      child_process.exec "phantomjs --load-images=no --ignore-ssl-errors=yes #{__dirname}/render.js '#{fullUrl}'", (error, stdout, stderr) ->
        if error or stderr
          next error || stderr
        else
          cb(stdout) if _.isFunction(cb)
          res.status(200).send(stdout)

    # Cache
    if options.store && options.store.ready
      cacheName = options.cachePrefix + fullUrl
      options.store.get cacheName, (err, result) ->
        if result
          res.status(200).send(result)
        else
          processDo (data) ->
            options.store.set cacheName, data
            if options.cacheLifetime
              options.store.expire cacheName, options.cacheLifetime
    else
      processDo()

middleware.middlewarePriority = -2