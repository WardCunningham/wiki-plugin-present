# present plugin, server-side component
# These handlers are launched with the wiki server. 

glob = require 'glob'
fs = require 'fs'

peers = (status) ->
  pattern = status.split('/').reverse()
  path = pattern[1].split('.')
  path[0] = '+([^.])'
  pattern[1] = path.join('.')
  pattern.reverse().join('/')

startServer = (params) ->
  app = params.app
  argv = params.argv

  # app.get '/plugin/present/:thing', (req, res) ->
  #   thing = req.params.thing
  #   res.json {thing}

  app.get '/plugin/present/roll', (req, res) ->
    # https://www.npmjs.com/package/glob
    glob "#{peers argv.status}/sitemap.json", {}, (err, files) ->
      return res.error(err) if err
      roll = for file in files
        sufix = if argv.port == 80 then '' else ":#{argv.port}"
        site = file.split('/').reverse()[2] + sufix
        path = file.replace /status\/sitemap\.json/, 'pages'
        pages = fs.readdirSync(path).length
        {site, pages}
      res.json {roll, files}

module.exports = {startServer}
