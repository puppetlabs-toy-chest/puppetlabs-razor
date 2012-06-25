# Razor Module

Puppet Razor module will perform the installation of Razor on Ubuntu Precise system. See [blog post](http://puppetlabs.com/blog/puppet-razor-module/).

## Dependencies

The puppet module tool in Puppet Enterprise 2.5.0+ and Puppet 2.7.14+ resolves dependencies automatically.

Puppet module dependencies for razor module:

* [apt module](https://github.com/puppetlabs/puppetlabs-apt)
* [Mongodb module](https://github.com/puppetlabs/puppetlabs-mongodb)
* [Node.js module](https://github.com/puppetlabs/puppetlabs-nodejs)
* [stdlib module](https://github.com/puppetlabs/puppetlabs-stdlib)
* [tftp module](https://github.com/puppetlabs/puppetlabs-tftp)
* [sudo module](https://github.com/saz/puppet-sudo)

## Installation

Install puppetlabs-node_gce module and dependencies into module_path:

    $ puppet module install puppetlabs-razor
    Preparing to install into /etc/puppet/modules ...
    Downloading from http://forge.puppetlabs.com ...
    Installing -- do not interrupt ...
    /etc/puppet/modules
    └─┬ puppetlabs-razor (v0.1.4)
      ├─┬ puppetlabs-mongodb (v0.0.1)
      │ └── puppetlabs-apt (v0.0.3)
      ├── puppetlabs-nodejs (v0.2.0)
      ├── puppetlabs-stdlib (v2.3.2)
      ├── puppetlabs-tftp (v0.1.1)
      ├── puppetlabs-vcsrepo (v0.0.4)
      └── saz-sudo (v2.0.0)

Puppet apply, apply test manifests:

    puppet apply razor/tests/init.pp

Puppet master, add razor class to target node:

    node razor_system {
      include razor
    }

## Parameters

* username: razor daemon username, default: razor.
* directory; installation target directory, default: /opt/razor.
* ruby_version: ruby version, supports 1.8.7 and 1.9.3, default: 1.9.3.

    class { 'razor':
      directory    => '/usr/local/razor',
      ruby_version => '1.8.7',
    }

## Usage

See [Razor](https://github.com/puppetlabs/Razor) and [Razor wiki pages](https://github.com/puppetlabs/Razor/wiki)
