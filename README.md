take-a-rest
===========

Simple RESTful Express server

# How to use it?

Preparation:
```coffeescript
takeARest = require 'take-a-rest'
express = require 'express'
mysql = require 'mysql'

pool = mysql.createPool
  host: 'localhost'
  user: 'root'
  password: ''
  database: 'dbname'
  

app = express()
app.use express.bodyParser()
app.use express.query()

restExpress = takeARest(app, pool)
```

Usage:
```coffeescript
restExpress(options)
```
Options:
```coffeescript
options = 
    # Required. The URL where the RESTful service is available
    url: string
    
    # Required. The name of the table in the database to associate with service
    tableName: string
    
    # The pool of MySQL connections.
    pool: mysql.createPool({})
    
    # The fields of the table that the client can access
    fields: commaSeparatedString
    
    # Middleware function. Could be used to control the generated query
    middleware: function (squelInstance, params, req, options) {}
    
    # Whether the request must return only one result
    # Useful for generating URLs like http://server.com/me
    single: false
    
    # If set to true DELETE method would be skipped
    forbitDeletes: false
    
    # If set to true UPDATE method would be skipped
    forbidAmmendments: false
    
    # If set to true INSERT method would be skipped
    forbidInserts: false
```

# Want some examples?

Here you go:
```coffeescript

# Request: GET /users
# Returns: id,name and surname of all users in the database
#
# Request: GET /users?limit=5&offset=0
# Returns: id,name and surname of 5 first users in the database
restExpress
  url: '/users'
  tableName: '7_users'
  fields: 'id,name,surname'

# Request: GET /users/4/projects
# Returns: id,user_id nad name of all rows from table 7_projects where column user_id equals 4
#
# Request: GET /users/4/projects?fields=id
# Returns: ids of all rows from table 7_projects where column user_id equals 4
restExpress
  url: '/users/:user_id/projects'
  tableName: '7_projects'
  fields: 'id,user_id,name'

# Request: GET /me/projects
# Returns: all projects that are associated with currently loggedin user
restExpress
  url: '/me/projects'
  tableName: '7_projects'
  middleware: (stmt, params, req) ->
    stmt = stmt.where('user_id = ?')
    params.push req.session.user_id

```


In the example above each ```restExpress()``` call creates 5 listeners.

In example, the first one listens to:
* GET /users
* GET /users/:id
* POST /users
* PUT /users/:id
* DELETE /users/:id
