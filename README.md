# Razor Module

Puppet Razor module will perform the installation of Razor on Ubuntu Precise system.

## Installation

https://github.com/puppetlabs/puppetlabs-razor

Here's a list of dependency for razor module:

* [apt module](https://github.com/puppetlabs/puppetlabs-apt)
* [Mongodb module](https://github.com/puppetlabs/puppetlabs-mongodb)
* [Node.js module](https://github.com/puppetlabs/puppetlabs-nodejs)
* [stdlib module](https://github.com/puppetlabs/puppetlabs-stdlib)
* [tftp module](https://github.com/puppetlabs/puppetlabs-tftp)
* [sudo module](https://github.com/saz/puppet-sudo)

Puppet master, add razor class to target node:

    node razor_system {
      include razor
    }

Puppet apply, apply test manifests:

    puppet apply razor/tests/init.pp

## Razor Usage

See [Razor project pages](https://github.com/puppetlabs/Razor)
