# Build different versions of [`getdns`](https://getdnsapi.net/)

Builds [`getdns`](https://getdnsapi.net/) on a Mac. After the build is done, a subsequent script is called for further testing. Used to test getdns against [other libraries and language adapters](https://github.com/getdnsapi) such as [getdns-node](https://github.com/getdnsapi/getdns-node).



## Usage

`getdns-build.sh <testing-script.sh> [-- test-option test-option ...]`

- Pass a test-script as the first argument, optionally a separator `--` and a number of options passed to the test-script.
- Before the test-script is run, the environment variable `GETDNS_TARGET` is set to the version of getdns which was just compiled.



---

Copyright © 2014, 2015, 2016, 2017, 2018 [Joel Purra](http://joelpurra.com/). Released under the [BSD 3-Clause License](https://opensource.org/licenses/BSD-3-Clause). Part of [`getdns`](https://getdnsapi.net/) developer support library [getdns-support](https://github.com/joelpurra/getdns-support)
