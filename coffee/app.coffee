http = require "http"
fs = require "fs"
request = require "request"
microtime = require "microtime"
path = require "path"
mime = require "mime"
Processor = require "./processor"
url = require "url"

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
    console.log "Rez is up and running at #{@port}"
    @srv.listen(@port, fn)
    @
  
  handle: (req, res) ->
    source = req.query.source
    fp = path.resolve __dirname, "../tmp/" + microtime.now()
    remote = request(source)
    console.log fp
    remote.pipe(fs.createWriteStream(fp));
    setTimeout () ->
      res.error new Error("Operation timeout")
    , 10*1000
    cleanup = () ->
      if fs.existsSync fp
        fs.unlinkSync fp
      if fs.existsSync "#{fp}_processed"
        fs.unlinkSync "#{fp}_processed"
    remote.on "error", (e) =>
      res.error e
    remote.on "end", () =>
      console.log "About to process localized file for #{source}"
      @processor.handle req.query, fp, (e, result) =>
        if e
          res.error e
          cleanup
        else
          console.log "Process done for #{source}"
          res.writeHead 200, "Content-Type": mime.lookup result.identity.format
          output = fs.createReadStream(result.dest)
          output.pip(res)
          output.on "end", cleanup
    
    
  
  @bootstrap: (port=process.env.PORT) ->
    app = (new App(port)).start()
  
module.exports =  App