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
  scriptPath = (path.resolve __dirname, p, 'hubot-scripts', 'src', 'scripts' \
    for p in module.paths).filter (p) -> fs.existsSync(p)
  console.log scriptPath
  scripts = require './hubot-scripts.json'
  robot.loadHubotScripts scriptPath[0], scripts
  robot.parseHelp path.join scriptPath[0], 'meme_captain.coffee'
  # load all hubot-* modules from package.json
  packageJson = require './package.json'
  pkgs = (pkg for own pkg, version of packageJson.dependencies \
          when !/^(coffee-script|hubot-scripts|hubot-help)$/.test(pkg))
  pkgs.forEach (p) -> (require p)(robot)
  # A special hack for hubot-help: ensure it replies via pm
  privRobot = Object.create robot
  privRobot.respond = (regex, cb) ->
    robot.respond regex, (resp) ->
      resp.message.private = true
      cb(resp)
  (require 'hubot-help')(privRobot)
  # A special hack for meme_captain: change its "respond"
  # invocations to "hear" so that it memes everywhere.
  memecaptain = require(path.resolve __dirname, scriptPath[0], 'meme_captain')
  memecaptain
    respond: (regex, cb) ->
      robot.hear regex, (msg) ->
        cb(msg) if msg.envelope.room is 'general/0' \
          or /^\s*[@]?(codex)?bot\b/i.test(msg.message.text)
  # done!
