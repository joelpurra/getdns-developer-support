# Semi-automated upgrading of [Native Abstractions for Node.js (NAN)](https://github.com/nodejs/nan)

Upgrades NAN usage from `v1.x.x` to `v2.x.x`. This enables using NAN on iojs v3.x/node v4/5/6.

Based on [Thorsten Lorenz](https://github.com/thlorenz)' script [`update_to_nan_v2.0.x.sh`](https://gist.github.com/thlorenz/7e9d8ad15566c99fd116). "Takes you 90% of the way"  -- or in the case of `getdns-node` 99% after some minor script modification.

See also NAN issue [#376 io.js v3 preparation](https://github.com/nodejs/nan/issues/376).



## Usage

`nan-upgrade-v1-to-v2.sh *.h *.cpp`



---

Copyright © 2014, 2015, 2016, 2017, 2018 [Joel Purra](https://joelpurra.com/). Released under the [BSD 3-Clause License](https://opensource.org/licenses/BSD-3-Clause). Part of [`getdns`](https://getdnsapi.net/) developer support library [getdns-support](https://github.com/joelpurra/getdns-support)
