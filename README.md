# dk

`dk` is a command line utility for quickly running pre-defined tasks stored in
a project's JSON-formatted `.dkrc` file.

## install

```
npm i -g dk
```

## usage

```
$ dk --help
Usage: dk [OPTIONS] [TASK] [CMD] [arg...]

Options:
  -c, --container=$(basename $(pwd))    Set container name
  --cwd=$(pwd)                          Set working directory
  -d, --detached                        Detach container, run in the background
  --debug                               Verbose dk output
  -e, --env=VAR=val                     Set container env vars
  -l, --link=containername:alias        Link to a running container
  --name=                               Name this container
  -p, --port=hostport:containerport     Bind host port to container port
  -s, --preset=key                      Load settings from .dkrc
  -v, --volume=hostpath:containerpath   Link a volume, relative paths are
                                        resolved from cwd

TASK is a key in the .dkrc file, if a match is present.

CMD [default=bash] is the command that will be run inside the container.

arg... are any args to be passed to the command running in the container.
```

In a directory with the same name as an available docker container, running
`dk` will be an alias for

```bash
docker run $(basename $(pwd)) bash
```

## dkb

Given a Dockerfile in the local directory, you can run `dkb` to quickly build
and tag the container as `[name of cwd]:latest`. `dkb` is simply an alias for:

```bash
docker build -t $(basename $(pwd)) .
```

## .dkrc

`.dkrc` is a JSON-formatted configuration file where keys are names of presets.
A key of `*` will apply the included settings to all invocations of `dk`.

Each task/preset may include the following keys:

Command to run:
```json
{"cmd":["my","cmd","--arg"]}
```
(or simply `"my cmd --arg"`)

Set environment variables:
```json
{"env":{"VAR_NAME":"value"}}
```

Link to running containers:
```json
{"link":{"container_name":"alias"}}
```

Name this container:
```json
{"name":"container_name"}
```

Bind ports:
```json
{"ports":{"3000":80}}
```

Link volumes:
```json
{"volume":{"/host/path":"/container/path"}}
```

## examples

Given the following example JSON file:

```json
{
  "*": {
    "env": {
      "MY_VAR": "global"
    }
  },
  "watch": {
    "cmd": [
      "gulp watch"
    ],
    "volumes": {
      ".": "/usr/src/app"
    }
  },
  "server": {
    "cmd": [
      "gulp server"
    ],
    "ports": {
      "3000": 80
    },
    "volumes": {
      ".": "/usr/src/app"
    }
  },
  "envtest": {
    "env": {
      "MY_VAR": "envtest"
    }
  },
  "printvar": {
    "cmd": [
      "sh",
      "-c",
      "echo \\$MY_VAR"
    ]
  },
  "lr": {
    "ports": {
      "35729": 35729
    }
  }
}
```

Then...

```
$ # check global env var
$ dk sh -c "echo \$MY_VAR"
global
$ # envtest overrides env var
$ dk envtest sh -c "echo \$MY_VAR"
envtest
$ # use printvar's cmd to echo
$ dk printvar
global
$ # precendence: *.env < [presets].env < task.env < dk -e
$ dk --preset=envtest printvar
envtest
$ # or override by set it yourself with an arg
$ dk -s envtest -e MY_VAR=overridden printvar
overridden
$ # but keep in mind, after TASK or CMD, args are passed through
$ dk printvar -e MY_VAR=overridden
global
$ # more practical, run 'gulp server' but optionally bind livereload port
$ dk server
Server listening on port 80
$ # docker ps -> 0.0.0.0:3000->80/tcp
$ dk -s lr server
Server listening on port 80
$ # docker ps -> 0.0.0.0:35729->35729/tcp, 0.0.0.0:3000->80/tcp
```

## Notes

While I am actively using this with my own projects, it is not
thoroughly tested and may not work as expected in all scenarios.
YMMV. Pull requests welcome. Please open an issue to discuss changes
prior to making them.
