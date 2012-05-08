# Razor Module

Puppet Razor module will perform the installation of Razor on Debian Wheezy system.

## Installation

https://github.com/puppetlabs/puppet-razor

Here's a list of dependency for razor module:

* [apt module](https://github.com/puppetlabs/puppet-apt)
* [Mongodb module](https://github.com/puppetlabs/puppetlabs-mongodb)
* [Node.js module](https://github.com/puppetlabs/puppetlabs-nodejs)
* [stdlib module](https://github.com/puppetlabs/puppetlabs-stdlib)
* [tftp module](https://github.com/puppetlabs/puppetlabs-tftp)

Puppet master, add razor class to target node:

    node razor_system {
      include razor
    }

Puppet apply, apply test manifests:

    puppet apply razor/tests/init.pp

## Razor Usage

See Razor project wiki pages.
