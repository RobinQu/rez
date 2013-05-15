im = require "imagemagick"
path = require "path"
microtime = require "microtime"

GravityMaps =
  n : "North"
  s: "South"
  w: "West"
  e: "East"
  nw: "NorthWest"
  ne: "NorthEast"
  sw: "SouthWest"
  se: "SouthEast"
  c: "Center"

class Processor

  @get: () ->
    @instance = new Processor

  identify: (fp, cb) ->
    im.identify fp, cb
  
  handle: (data, cb) ->
    options = data.parameters
    mode = options.mode or "crop"
    dest = data.dest
    fp = data.fp
    quality = options.quality or 0.8
    # console.log fp
    @identify fp, (e, features) ->
      if e
        console.error "unable to recongnize source image file"
        cb e
      else
        callback = (e) ->
          if e
            cb e
          else
            cb null, dest: dest, identity: features
        switch mode
          when "resize"
            # resize mode
            if options.width or options.height
              im.resize 
                srcPath: fp
                dstPath: dest
                quality: quality
                width: options.width or 0
                height: options.height or 0
              , callback
            else
              cb new Error "missing parameter width or height"
          when "crop"
            # crop mode
            [w, h] = options.resize.toLowerCase().split "x" if options.resize
            w = options.width if options.width
            h = options.width if options.width
              
            if w and h
              im.crop 
                srcPath: fp
                dstPath: dest
                width: w
                height: h
                quality: quality
                gravity: GravityMaps[options.graivity or "n"]
              , callback
            else
              cb new Error "missing parameter `resize`"

module.exports = Processor