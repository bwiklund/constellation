express = require 'express'
elasticsearch = require 'elasticsearch'
sanitizeHtml = require 'sanitize-html'

client = elasticsearch.Client()

app = express()

app.use (i,o,next) ->
  pathToDir =      (path) -> path.split('/')[...-1].join('/')
  pathToFilename = (path) -> path.split('/')[-1..][0]
  o.locals {sanitizeHtml,pathToDir,pathToFilename}
  next()

health = null # TODO: cache this properly instead of being dumb
client.cluster.health (err,resp) -> health = resp

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
  app.use '/public', express.static __dirname + '/public'

app.get "/", (i,o) ->

  query = i.query.q
  search(query)
  .then (results) ->
    o.render 'index', {results,query,health}
  , (err) ->
    o.send err

app.get "/json", (i,o) ->
  search(i.query.q)
  .then (results) ->
    o.send results
  , (err) ->
    o.send err

app.listen 8765
console.log "fmjs is listening on 8765"