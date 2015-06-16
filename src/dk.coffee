fs = require 'fs'
path = require 'path'
{exec} = require 'child_process'

_ = require 'lodash'

getArgs = require './getArgs'
args = getArgs process.argv

args.cwd = args.cwd?[0] ? process.env.PWD
args.detached = args.detached == true
args.taskName = args.taskName ? args.dkcmd.shift()

if args.debug
  console.log process.argv
  console.log args

getTask = require './getTask'
task = getTask args

container = path.basename args.cwd

daemonOrNot = if args.detached == true
  '-d'
else
  "--rm#{if task.cmd[0] == 'bash' then ' -it' else ''}"

for word, index in task.cmd
  if word.indexOf(' ') != -1
    word = "\"#{word}\""
  task.cmd[index] = word

cmd = ["docker run #{daemonOrNot}"]
  .concat _.map (task.volumes ? {}), (target, source) ->
    source = path.resolve args.cwd, source
    ['-v', "#{source}:#{target}"]
  .concat _.map (task.env ? {}), (val, name) ->
    if val?.charAt?(0) == '.'
      val = path.resolve args.cwd, val
    ['-e', "#{name}=#{val}"]
  .concat _.map (task.ports ? {}), (hostPort, containerPort) ->
    ['-p', "#{containerPort}:#{hostPort}"]
  .concat (if task.name then ["--name=#{task.name}"] else [])
  .concat container
  .concat task.cmd

cmd = _.flatten(cmd).join ' '

if task.name
  exec "docker stop #{task.name}", (err, stdout, stderr) ->
    exec "docker rm #{task.name}", (err, stdout, stderr) ->
      console.log cmd
else
  console.log cmd
