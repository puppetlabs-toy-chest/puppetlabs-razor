# Razor Module

[Puppet Razor][razor] module will perform the installation of Razor, a bare
metal and virtual machine provisioning solution.  Razor is next generation
provisioning software that handles bare metal hardware and virtual server
provisioning with inventory discovery and tagging, rule-based policy
management, and extensible broker plugin integration.

See the [original release announcement blog post](http://puppetlabs.com/blog/puppet-razor-module/)
for more details about this module, and Razor.

This module initially supported only Ubuntu Precise, although we would like -
and will happily accept patches - to support other server platforms for Razor.
It should currently work correctly on most platforms.

There is nothing all that inherently platform specific about what we do here.
Most of the challenges come from finding a suitable source of nodejs.

It is considered part of the overall [Project Razor infrastructure][razor], so
you can get help using the module or enhancing it over at the main
[Project Razor site on GitHub][razor].

[razor]: https://github.com/puppetlabs/razor


## What this installs

Each release of the Puppet Labs Razor module will install one specific version
of Razor.  To obtain a newer version of Razor you must also download and use a
newer version of the Puppet module.

Not all modules work like this, and we are well aware that it imposes a
non-trivial burden on you as the end user.  Given that, why did we choose
this path?

Razor itself is not yet stable - the leading zero in the version number
indicates that.  That makes for larger and more disruptive changes than other,
more stable projects encounter.

When Razor reaches the 1.0.0 milestone, and beyond, this policy will probably
change: dependencies will be settled, formats solidified, and incompatible
change rare.

Until then this is the least bad solution.  If we ensure that the Puppet
module, and any dependency and change handling that it brings are up to date,
we also ensure that the user experience of deploying Razor is most likely to
be successful.


## Installation

To install puppetlabs-razor module and dependencies into module_path, use the
standard `puppet module install puppetlabs-razor` command.  This will fetch
the Razor module, and all dependent modules, for you.

On the Puppet master, add the sudo and razor classes to target node.
**WARNING**: Including the `sudo` class, which is required for Razor to work,
may change the setup of a security critical part of your system.

Please be careful with this change, and don't rush in.  Ensure that you will
still have access to the target node before you mess with access rights.

    node razor_system {
      # WARNING: be very, very careful, as this changes your SUDO setup!
      class { 'sudo': config_file_replace => false }
      include razor
    }


## Upgrading

A key goal of the Puppet Razor module is to be as transparently compatible as
possible: if we can possibly make an upgrade a non-issue, we will.

You can normally upgrade using `puppet module upgrade`, and then rerunning
Puppet to update the system.  This should bring your installation into line
with the newest stable release from Puppet Labs.


### Upgrading from 0.6.1 or earlier

Until release 0.6.1, the default (or only) installation method was using a
direct checkout from the git source tree.  That treated all our users as if
they were developers, including directly giving them untested or lightly
tested code that had only just been accepted into the project.

With 0.7.0 that changed.  Now the default is to install the stable release
tar, and users who want to follow nightly versions will have to manually
manage that installation.

If you used git in 0.6.1 or earlier, add `source => git` to your Razor class configuration; an example would be:

    node razor_system {
      class { razor: source => git }
    }

Razor will refuse to install - the Puppet run will fail - if you try to
install directly from tar over an existing git deployment.  This should
prevent users being surprised when the two conflict.

To migrate from a git install to a tar (or package) install, it is sufficient
to delete `/opt/razor/.git` (or the `.git` directory from whatever location
you installed Razor.)


## Parameters

* source: `tar`, or `package`, or `git`; default: `tar`
  - this selects what installation method is used for getting Razor on the system
  - `tar` is the default, and recommended, strategy.
  - `package` requires that you add appropriate repositories *yourself*; not yet recommended, but it is at least vaguely supported.
  - `git` is not recommended for use; if you want a git install, you should do it by hand!  This is to support legacy installations only.
* username: razor daemon username, default: razor.
* directory; installation target directory, default: /opt/razor.
* address: razor.ipxe chain address, and razor service listen address, default: facter ipaddress.
* persist_host: ip address of the mongodb server, default: 127.0.0.1.
* mk_checkin_interval: mk checkin interval, default: 60 seconds.
* mk_name: razor tiny core linux mk name.
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

rz_model, rz_tag, rz_policy supports deployment of operating systems:

    rz_model { 'precise_model':
      ensure      => present,
      description => 'Ubuntu Precise Model',
      image       => 'precise_image',
      metadata    => {
        'domainname'      => 'puppetlabs.lan',
        'hostname_prefix' => 'openstack',
        'rootpassword'    => 'puppet',
      },
      template    => 'ubuntu_precise',
    }

    rz_tag { 'virtual':
      tag_label   => 'virtual',
      tag_matcher => [
        { 'key'     => 'is_virtual',
          'compare' => 'equal',
          'value'   => 'true',
          'inverse' => false, }
      ],
    }

    rz_policy { 'precise_policy':
      ensure   => 'present',
      broker   => 'none',
      model    => 'precise_model',
      enabled  => 'true',
      tags     => ['virtual'],
      template => 'linux_deploy',
      maximum  => 1,
    }

    rz_broker { 'demo':
      plugin  => 'puppet',
      metadata => {
        version => '3.0.2',
        server  => 'puppet.dmz25.lab',
      }
    }

Additional examples can be found in the tests directory. Currently rz\_\* resources only creates/delete configuration, and does not manage(maintain) razor configuration.

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


## Contributors

Special thanks to Craig Dunn [@crayfishx](https://github.com/crayfishx) for adding RHEL support for razor dependency modules.

Bill ONeill <woneill@pobox.com>  
Branan Purvine-Riley <branan@puppetlabs.com>  
Chad Metcalf <chad@wibidata.com>  
Gary Larizza <gary@puppetlabs.com>  
geauxvirtual <justin.guidroz@gmail.com>  
Pierre-Yves Ritschard <pyr@spootnik.org>  
Rémi <remi@binbash.fr>  
Stephen Johnson <stephen@puppetlabs.com> <steve@thatbytes.co.uk>  
Street Preacher <preachermanx@gmail.com>  
