fs = require 'fs'
path = require 'path'
_ = require 'lodash'

mergeOpts = (obj1, obj2) ->
  return unless obj2
  for k, v of obj2
    if typeof v is 'object'
      obj1[k] = _.merge (obj1[k] ? {}), obj2[k]
    else
      obj1[k] = v
  return

mergeOptsSoft = (obj1, obj2) ->
  return unless obj2
  for k, v of obj2
    if !obj1[k]
      obj1[k] = obj2[k]
    else
      for k2, v2 of obj2[k]
        if !obj1[k][k2]
          obj1[k][k2] = obj2[k][k2]
  return

mergeArgs = (obj, _args, delimiter = ':') ->
  return unless _args?.length > 0
  for arg in _args
    [srcOpt, destOpt] = arg.split delimiter
    obj[srcOpt] = destOpt
  return

getTask = (args) ->
  dkrcFile = path.join args.cwd, '.dkrc'
  unless fs.existsSync dkrcFile
    console.error "ERROR: No .dkrc file found in #{cwd}"
    process.exit 1

  dkrc = JSON.parse fs.readFileSync dkrcFile

  if !dkrc[args.taskName] and args.taskName?.length > 0
    unless args.dkcmd?.length > 0
      args.dkcmd = []
    args.dkcmd.unshift args.taskName

  task = dkrc[args.taskName]
  unless task
    task = {}

  # add in global presets
  if dkrc['*']
    mergeOptsSoft task, dkrc['*'] if dkrc['*']

  if args.preset?.length > 0
    for preset in args.preset
      mergeOpts task, dkrc[preset] if dkrc[preset]

  task.links = {} unless task.links
  mergeArgs task.links, args.link
  task.ports = {} unless task.ports
  mergeArgs task.ports, args.port
  task.env = {} unless task.env
  mergeArgs task.env, args.env, '='
  task.volumes = {} unless task.volumes
  mergeArgs task.volumes, args.volume

  if args.name?.length > 0
    task.name = args.name[0]

  if args.dkcmd?.length > 0 and args.dkcmd[0].charAt(0) != '-'
    task.cmd = args.dkcmd
  unless task.cmd?.length > 0
    task.cmd = ['bash']
  if args.dkcmd?.length > 0 and args.dkcmd[0].charAt(0) == '-'
    task.cmd = task.cmd.concat args.dkcmd

  task

module.exports = getTask
