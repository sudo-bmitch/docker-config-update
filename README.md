# Docker Config and Secret Update Tool

This utility will update configs and secrets in docker based on a local
source file. The configs and secrets are versioned and the version is appended
to the config and secret name. An environment variable file is updated with
the latest version number of the configs and secrets. This file can then be
sourced before deploying a stack in docker to use the latest versions.

## The .docker-deploy file

This file contains the following lines:

- `CONFIG_LIST=`: space separated list of configs.
- `SECRET_LIST=`: space separated list of secrets.
- `ENV_FILE=`: filename to update with config and secret variables,
  defaults to `.env`.
- `STACK_NAME=`: stack name, used to namespace configs/secrets to
  automatically cleanup when the stack is removed.
- For each config name in the list above:
  - `CONF_name_SRC_FILE=`: filename to read a config from, name is a variable.
  - `CONF_name_SRC_TYPE=`: change from the default "file" type, can be "latest"
    to use the most recent version.
  - `CONF_name_TGT_NAME=`: name of config to create, appended with a version.
  - `CONF_name_TGT_VAR=`: variable to update in environment file.
- For each secret name in the list above:
  - `SEC_name_SRC_FILE=`: filename to read a secret from, name is a variable.
  - `SEC_name_SRC_TYPE=`: change from the default "file" type, can be "latest"
    to use the most recent version, and "random" to randomly initialize a
    value.
  - `SEC_name_TGT_NAME=`: name of secret to create, appended with a version.
  - `SEC_name_TGT_VAR=`: variable to update in environment file.
- `OPT_ONLY_LATEST=`: set to 1 to prevent old versions of a config/secret from
  being used, forces creation of a new entry even if old ones match.
- `OPT_PRUNE_UNUSED=`: set to 1 to cleanup unused versions of configs and
  secrets. This currently blindly deletes all configs/secrets other than the
  active one, ignoring errors from those that are still in use.

## The .env file

This file will contain lines with each `CONF_name_TGT_VAR` and
`SEC_name_TGT_VAR` defined in the `.docker-deploy` file (where name is from the
list of configs and secrets).

## Using with a compose file

Your compose file will need to define external configs and secrets. With
version 3.5 of the compose file, you define external configs and secrets with
a name using the following syntax:

```
version: '3.5'

configs:
  app_conf:
    external: true
    name: app_conf_${app_conf_ver}
secrets:
  app_sec:
    external: true
    name: app_sec_${app_sec_var}
services:
  app:
    image: app_image
    configs:
      - source: app_conf
        target: /etc/app.conf
        mode: 444
    secrets:
      - source: app_sec
        target: /etc/app.sec
        mode: 400
        uid: "0"
```

When deploying the stack, you'll want to run:

```
# update the .env file with this script
docker-config-update
# source and export the .env file
set -a && . ./.env && set +a
# deploy the stack with the variables
docker stack deploy -c docker-compose.yml app
```

## Random secrets

These are a 32 character string created with:

```
base64 -w 0 </dev/urandom | head -c 32
```

This entry will only be created if missing with a version of 1. Otherwise the
latest version of this secret is saved to the environment file.

## License

This script is released under the MIT license.

