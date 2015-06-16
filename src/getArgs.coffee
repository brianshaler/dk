path = require 'path'

pkg = require '../package.json'

collect = (val, memo) ->
  memo.concat val

getArgs = (argv = process.argv, flags, options) ->
  flags = getArgs.flags unless flags
  options = getArgs.options unless options

  args = Array.prototype.slice.call argv, 2

  pattern = /-?([a-zA-Z])?(, )?--?([a-zA-Z\-]+)?/
  result =
    dkcmd: []

  allFlags = {}

  for flag in flags
    match = pattern.exec flag
    if match?.length >= 4
      [blah, short, comma, long] = match
      name = long ? short
      allFlags[long] = name if long?.length > 0
      allFlags[short] = name if short?.length > 0
      result[name] = false

  longs = {}
  shorts = {}
  allOptions = {}
  for option in options
    match = pattern.exec option
    if match?.length >= 4
      [blah, short, comma, long] = match
      name = long ? short
      # longs[name] = long if long?.length > 0
      # shorts[name] = short if short?.length > 0
      allOptions[long] = name if long?.length > 0
      allOptions[short] = name if short?.length > 0

  shortPattern = /^-([a-zA-Z]+)/
  longPattern1 = /^--([a-zA-Z]+)=(.+)/
  longPattern2 = /^--([a-zA-Z]+)$/

  skip = false
  for index in [0..args.length-1] by 1
    arg = args[index]
    if skip
      skip = false
      continue
    match = shortPattern.exec arg
    if match?.length > 1
      flags = match[1].split ''
      if flags.length > 1
        for i in [0..flags.length-2] by 1
          flag = flags[i]
          if allFlags[flag]
            result[allFlags[flag]] = true
          else
            throw new Error "Unrecognized option -#{flag}"
      flag = flags[flags.length-1]
      if allFlags[flag]
        result[allFlags[flag]] = true
      else if allOptions[flag]
        skip = true
        unless result[allOptions[flag]]?.length > 0
          result[allOptions[flag]] = []
        result[allOptions[flag]].push args[index+1]
      else
        throw new Error "Unrecognized option -#{flag}"
      continue
    match = longPattern1.exec arg
    if match?.length > 2
      key = match[1]
      val = match[2]
      if allOptions[key]
        unless result[allOptions[key]]?.length > 0
          result[allOptions[key]] = []
        result[allOptions[key]].push match[2]
      continue
    match = longPattern2.exec arg
    if match?.length > 1
      key = match[1]
      if allFlags[key]
        result[allFlags[key]] = true
        continue
      else
        val = args[index+1]
        skip = true
        if allOptions[key]
          unless result[allOptions[key]]?.length > 0
            result[allOptions[key]] = []
          result[allOptions[key]].push args[index+1]
          continue
      throw new Error "Unrecognized option #{arg}"
    result.dkcmd = args.slice index
    break

  result

getArgs.flags = [
  '-d, --detached'
  '--debug'
]

getArgs.options = [
  '-c, --container'
  '-v, --volume'
  '-l, --link'
  '-e, --env'
  '-p, --port'
  '-s, --preset'
  '--name'
  '--cwd'
]

module.exports = getArgs
