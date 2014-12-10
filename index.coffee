fs = require 'fs'
path = require 'path'

process.env.HUBOT_GOOGLE_HANGOUTS_DOMAIN = 'cscott.net'

module.exports = (robot) ->
  # load all scripts in scripts/
  scriptPath = path.resolve __dirname, 'scripts'
  for file in fs.readdirSync(scriptPath)
    continue unless /\.(coffee|js)$/.test(file)
    robot.loadFile scriptPath, file
  # load all scripts from hubot-scripts
  scriptPath = path.resolve __dirname, 'node_modules', \
    'hubot-scripts', 'src', 'scripts'
  scripts = require './hubot-scripts.json'
  robot.loadHubotScripts scriptPath, scripts
  # load all hubot-* modules from package.json
  packageJson = require './package.json'
  pkgs = (pkg for own pkg, version of packageJson.dependencies \
          when !/^(coffee-script|hubot-scripts)$/.test(pkg))
  pkgs.forEach (p) -> (require p)(robot)
  # A special hack for meme_captain: change its "respond"
  # invocations to "hear" so that it memes everywhere.
  memecaptain = require './node_modules/hubot-scripts/src/scripts/meme_captain'
  memecaptain
    respond: (regex, cb) ->
      robot.hear regex, (msg) ->
        cb(msg) if msg.envelope.room is 'general/0' \
          or /^\s*[@]?(codex)?bot\b/i.test(msg.message.text)
  # done!
