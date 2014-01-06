express = require 'express'

app = express()

app.configure ->
  app.use require('connect-assets')()
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'

app.get "/", (i,o) ->
  o.render 'index'

app.get "/search/:query?", (i,o) ->
  query = i.params.query || ''
  o.render 'index', {query}

app.listen 8765
console.log "fmjs is listening on 8765"