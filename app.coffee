express = require 'express'
elasticsearch = require 'elasticsearch'

client = elasticsearch.Client()

app = express()


search = (query) ->
  client.search
    index: 'constellation'
    type: 'file'
    size: 20
    body:
      query:
        wildcard:
          contents: query
      highlight:
        fields:
          contents:
            fragment_size: 150
            number_of_fragments: 3

      partial_fields: # trim full file contents from response
        contents:
          include: ['path']


app.configure ->
  app.use require('connect-assets')()
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'

app.get "/", (i,o) ->
  o.render 'index'

app.get "/search/:query?", (i,o) ->
  search(i.params.query)
  .then (results) ->
    o.render 'index', {results}
  , (err) ->
    o.send err

app.get "/test/:query", (i,o) ->
  search(i.params.query)
  .then (results) ->
    o.send results
  , (err) ->
    o.send err

app.listen 8765
console.log "fmjs is listening on 8765"