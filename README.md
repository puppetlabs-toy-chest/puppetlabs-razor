# Razor Module

Puppet Razor module will perform the installation of Razor software dependency
on Debian Wheezy system.

## Installation

https://github.com/puppetlabs/puppet-razor

Here's a list of dependency for razor module:

* [apt module](https://github.com/puppetlabs/puppet-apt)
* [stdlib module](https://github.com/puppetlabs/puppet-stdlib)
* [Node.js module](https://github.com/nanliu/puppet-nodejs)
* [Mongodb module](https://github.com/nanliu/puppet-mongodb)
* [tftp module](https://github.com/nanliu/puppet-tftp)

Puppet master, add razor class to target node:

    node razor_system {
      include razor
    }

Puppet apply, apply test manifests:

    puppet apply razor/tests/init.pp

git clone razor private repo to the system.

    git clone git@github.com:nanliu/Razor.git
