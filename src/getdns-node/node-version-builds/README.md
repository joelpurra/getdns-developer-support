# Semi-automated compilation and testing of [getdns-node](https://github.com/getdnsapi/getdns-node) against different versions of [`node`](https://nodejs.org/)

Compiles/builds/installs using `npm install` and subsequently runs `npm test` of [`getdns-node`](https://github.com/getdnsapi/getdns-node) against different versions of [`node`](https://nodejs.org/). This way compatibility can be confirmed, and possibly incompatibilities found.

## Requirements

- [`n`](https://github.com/tj/n) for node version management.

## Usage

`node-version-builds.sh <git repository> <commitish>`

- Relies on the environment variable `GETDNS_NODE_TARGET` being set, as it's used for output directories and log naming.
- Pass a git repository and a commitish (commit hash, tag or branch name) to have it automatically cloned and/or cleaned before the build.
- The subfolder `getdns-node-builds/` will contain separate build folders and log output from `npm install` and `npm test`.


---

Copyright © 2014, 2015, 2016, 2017, 2018 [Joel Purra](https://joelpurra.com/). Released under the [BSD 3-Clause License](https://opensource.org/licenses/BSD-3-Clause). Part of [`getdns`](https://getdnsapi.net/) developer support library [getdns-support](https://github.com/joelpurra/getdns-support)
