elasticsearch = require 'elasticsearch'
async = require 'async'
walk = require 'walk'
fs = require 'fs'

client = new elasticsearch.Client()

addFile = (file,cb) ->
  filename = 'foobar' + (""+Math.random())[2..]
  client.index
    index: 'constellation',
    type: 'file',
    id: file.path
    body: file
  , cb

# todo: bulk insert or .cargo
# async.mapSeries [0..10000], addFile, (err,resp) ->
#   console.log resp.length + ' files upserted'
#   process.exit()


walker = walk.walk './repos/node_modules',
  followLinks: false
  #filters: ['foo','bar']

walker.on 'file', (root,stats,next) ->
  path = root + '/' + stats.name
  fs.readFile path, (err,contents) ->
    contents = contents.toString()
    addFile {path,contents}, ->
      console.log 'saved', path
      next()

walker.on 'end', ->
  process.exit()