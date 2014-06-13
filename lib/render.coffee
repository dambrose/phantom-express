system = require 'system'
webpage = require 'webpage'

url = system.args.slice(-1)

# Define functions
die = (message) ->
  console.log message
  phantom.exit()


done = ->
  parser = ->
    document.documentElement.outerHTML.replace /\<script type="text\/javascript"( (charset|async|data-requirecontext|data-requiremodule|src)="[^"]*")+><\/script>/ig, ''

  die page.evaluate parser


# Check if the URL was supplied
die "no url supplied\n" unless url

# Initialization
page = webpage.create()

page.viewportSize =
	width: 1024
	height: 768

resources = 0
resourcesTimer = null


# Page event bindings
page.onResourceRequested = (request) ->
  resources++

page.onResourceReceived = (response) ->
  if --resources is 0
    clearTimeout resourcesTimer if resourcesTimer
    resourcesTimer = setTimeout done, 2500


#page.onConsoleMessage = (msg) -> console.log('Page title is ' + msg)

# Load the page
page.open url, (status) -> die "Phantom: could not open url #{url} \n" if status is "fail"