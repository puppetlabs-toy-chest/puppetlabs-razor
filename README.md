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
      class { 'sudo':
        config_file_replace => false,
      }
      include razor
    }

## Parameters

* username: razor daemon username, default: razor.
* directory; installation target directory, default: /opt/razor.
* address: razor.ipxe chain address, default: facter ipaddress.
* mk_source: razor mk iso source, default: [Razor-Microkernel project](https://github.com/downloads/puppetlabs/Razor-Microkernel) production iso.


    file { 'custom_mk.iso':
      path   => '/var/tmp/custom_mk.iso',
      source => 'puppet:///acme_co/files/custom_mk.iso',
    }

    class { 'razor':
      directory => '/usr/local/razor',
      mk_name   => 'rz_mk_custom-image.0.9.0.4.iso',
      mk_source => '/var/tmp/custom_mk.iso',
      require   => File['custom_mk.iso'],
    }

## Resources

rz_image allows management of images available for razor:

    rz_image { 'VMware-VMvisor-Installer-5.0.0-469512.x86_64.iso':
      ensure  => 'present',
      type    => 'esxi',
      source  => '/opt/image/VMware-VMvisor-Installer-5.0.0-469512.x86_64.iso',
    }

    rz_image { 'Precise':
      ensure  => 'present',
      type    => 'os',
      version => '12.04',
      source  => '/opt/image/ubuntu-12.04-server-amd64.iso',
    }

* Although we can query uuid, it can not be specified.

## Usage

See [Razor](https://github.com/puppetlabs/Razor) and [Razor wiki pages](https://github.com/puppetlabs/Razor/wiki)
