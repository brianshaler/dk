fs = require 'fs'
path = require 'path'
{exec} = require 'child_process'

_ = require 'lodash'
optimist = require 'optimist'

argv = optimist
  .default 'cwd', __dirname
  .default 'd', false
  .argv

daemon = argv.d != false

container = argv._[0]

subcmd = Array::slice.call process.argv, 3
extradk = []
dkparams = [
  '-v'
  '-e'
  '--link'
  '-p'
]
while subcmd.length > 0 and subcmd[0].charAt(0) == '-'
  param = subcmd.shift()
  isdk = false
  for dkp in dkparams
    if param.substring(0, dkp.length) == dkp
      isdk = true
  if isdk
    extradk.push param
    unless param.charAt(1) == '-'
      extradk.push subcmd.shift()

taskName = if subcmd.length > 0
  subcmd.join ' '
else
  'bash'

cwd = argv.cwd

filepath = path.join cwd, './.dockerrc'

daemonOrNot = if daemon == true
  '-d'
else
  '--rm -it'

getJSON = (next) ->
  fs.exists filepath, (exists) ->
    unless exists
      return next null, {}
    fs.readFile filepath, (err, contents) ->
      return next err if err
      try
        tasks = JSON.parse contents
      catch err
        return next err if err
      next null, tasks

getJSON (err, tasks) ->
  if err
    console.error err.stack ? err
    process.exit 1

  task = tasks[taskName]

  unless task
    task =
      cmd: taskName

  if tasks['*']
    task = _.merge tasks['*'], task

  cmd = ["docker run #{daemonOrNot}"]
    .concat extradk
    .concat _.map (task.volumes ? {}), (target, source) ->
      source = path.resolve cwd, source
      ['-v', "#{source}:#{target}"]
    .concat _.map (task.env ? {}), (val, name) ->
      if val?.charAt?(0) == '.'
        val = path.resolve cwd, val
      ['-e', "#{name}=#{val}"]
    .concat _.map (task.ports ? {}), (hostPort, containerPort) ->
      ['-p', "#{containerPort}:#{hostPort}"]
    .concat (if task.name then ["--name=#{task.name}"] else [])
    .concat [
      container
    ]
    .concat task.cmd

  cmd = _.flatten(cmd).join ' '
  if task.name
    exec "docker stop #{task.name}", (err, stdout, stderr) ->
      exec "docker rm #{task.name}", (err, stdout, stderr) ->
        console.log cmd
  else
    console.log cmd
