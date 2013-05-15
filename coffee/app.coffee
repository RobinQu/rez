http = require "http"
fs = require "fs"
request = require "request"
microtime = require "microtime"
path = require "path"
mime = require "mime"
Processor = require "./processor"
url = require "url"
cluster = require "cluster"

class App

  constructor: (@port=5432) ->
    @root = path.resolve __dirname, "../tmp/"
    @processor = Processor.get()
    if !fs.existsSync @root
      fs.mkdirSync @root
    @srv = http.createServer((req, res) =>
      ps = url.parse req.url, true
      req.query = ps.query;
      res.error = (e) ->
        console.log "Failed to process #{req.query.source}"
        res.writeHead 500
        res.end e.message or e
      @handle req, res
    )
  
  start: (fn) ->
    if not cluster.isWorker 
      console.log "Rez is up and running at #{@port}"
    @srv.listen(@port, fn)
    @
  
  handle: (req, res) ->
    source = req.query.source
    extname = path.extname source
    salt = microtime.now()
    if !source or !req.query.mode
      res.error new Error("missing parameters")
      return
    fp = path.resolve __dirname, "../tmp/#{salt}#{extname}"
    dest = path.resolve __dirname, "../tmp/#{salt}_processed#{extname}"
    timer = setTimeout () ->
      res.error new Error("Operation timeout")
    , 20*1000
    cleanup = () ->
      console.log "cleanup..."
      if fs.existsSync fp
        fs.unlinkSync fp
      if fs.existsSync dest
        fs.unlinkSync dest
      
    remote = request(source)
    remote.pipe fs.createWriteStream(fp)
    remote.on "error", (e) ->
      clearTimeout timer
      cleanup
      res.error e
    remote.on "end", () =>
      console.log "About to process localized file for #{source}"
      @processor.handle parameters: req.query, fp:fp, dest:dest , (e, result) =>
        clearTimeout timer
        if e
          res.error e
          cleanup()
        else
          console.log "Process done for #{source}"
          res.writeHead 200, 
            "Content-Type": mime.lookup result.identity.format
            "X-Original-Width": result.identity.width
            "X-Original-Height": result.identity.height
            
          output = fs.createReadStream(result.dest)
          output.pipe(res)
          output.on "end", cleanup
      
  @bootstrap: (port=process.env.PORT) ->
    app = (new App(port)).start()
  
module.exports =  App