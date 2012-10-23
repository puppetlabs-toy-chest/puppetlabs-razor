# Razor Module

[Puppet Razor][razor] module will perform the installation of Razor on Ubuntu Precise system. See [blog post](http://puppetlabs.com/blog/puppet-razor-module/).

It is considered part of the overall [Project Razor infrastructure][razor], so you can get
help using the module or enhancing it over at the main [Project Razor site on GitHub][razor].

[razor]: https://github.com/puppetlabs/razor

## Dependencies

The puppet module tool in Puppet Enterprise 2.5.0+ and Puppet 2.7.14+ resolves dependencies automatically.

Puppet module dependencies for razor module:

* [apt module](https://github.com/puppetlabs/puppetlabs-apt)
* [Mongodb module](https://github.com/puppetlabs/puppetlabs-mongodb)
* [Node.js module](https://github.com/puppetlabs/puppetlabs-nodejs)
* [Ruby module](https://github.com/puppetlabs/puppetlabs-ruby)
* [stdlib module](https://github.com/puppetlabs/puppetlabs-stdlib)
* [tftp module](https://github.com/puppetlabs/puppetlabs-tftp)
* [vcsrepo module](https://github.com/puppetlabs/puppetlabs-vcsrepo)
* [sudo module](https://github.com/saz/puppet-sudo)

## Installation

Install puppetlabs-razor module and dependencies into module_path:

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
* address: razor.ipxe chain address, and razor service listen address, default: facter ipaddress.
* persist_host: ip address of the mongodb server, default: 127.0.0.1.
* mk_checkin_interval: mk checkin interval, default: 60 seconds.
* mk_name: razor tiny core linux mk name.
* mk_source: razor mk iso source, default: [Razor-Microkernel project](https://github.com/downloads/puppetlabs/Razor-Microkernel) production iso.
* git_source: razor git repo source, default: [Puppet Labs Razor](https://github.com/puppetlabs/Razor.git) .
* git_revision: razor git repo revision, default: master.

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

## Contributors

Special thanks to Craig Dunn [@crayfishx](https://github.com/crayfishx) for adding RHEL support for razor dependency modules.

Bill ONeill <woneill@pobox.com>  
Branan Purvine-Riley <branan@puppetlabs.com>  
Chad Metcalf <chad@wibidata.com>  
Gary Larizza <gary@puppetlabs.com>  
Pierre-Yves Ritschard <pyr@spootnik.org>  
Rémi <remi@binbash.fr>  
Stephen Johnson <stephen@puppetlabs.com> <steve@thatbytes.co.uk>  
Street Preacher <preachermanx@gmail.com>  
