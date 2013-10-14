# Razor Module

[Puppet Razor][razor] module will installation the Razor server on EL6, Debian
7, and Ubuntu 12.04, or newer versions of those platforms.  It should be
reasonably portable across platforms, and has decent support for failing well
on unsupported platforms.

It is considered part of the overall [Project Razor infrastructure][razor], so
you can get help using the module or enhancing it over at the main
[Project Razor site on GitHub][razor].

[razor]: https://github.com/puppetlabs/razor-server

## Dependencies

The puppet module tool in Puppet Enterprise 2.5.0+ and Puppet 2.7.14+ resolves dependencies automatically.

Puppet module dependencies for razor module:

* [Java module](http://forge.puppetlabs.com/puppetlabs/java)

## Installation

Install puppetlabs-razor module and dependencies into module_path:

    $ puppet module install puppetlabs-razor
    Preparing to install into /etc/puppet/modules ...
    Downloading from http://forge.puppetlabs.com ...
    Installing -- do not interrupt ...
    /etc/puppet/modules
    └─┬ puppetlabs-razor (v0.7.0)
      └─┬ puppetlabs-java (v1.0.1)
        └── puppetlabs-stdlib (v4.1.0)

Then, on your Puppet master, add razor class to target node -- or just use `puppet apply` as normal:

    node razor_system {
      include razor
    }


## Post-Install Setup

Once the Razor server is installed, you have a handful of tasks to complete:

1. Install PostgreSQL and create a Razor database.
   - razor-server requires a TCP connection to the database, due to JDBC driver limitations.
2. `cp /opt/razor/config.yaml.sample /opt/razor/config.yaml`
3. Edit that file to reflect your local settings.
4. Run `razor-admin -e production migrate-database` to update the database content.
5. Configure your DHCP service.
   - see `examples/isc-dhcpd-example.conf` for an example with the ISC DHCP daemon.
   - see [the wiki documentation for PXE setup for full and gory details](https://github.com/puppetlabs/razor-server/wiki/Installation#wiki-pxe)

At that point everything should be working correctly.


## Razor Client

This module does not install the Razor client, used to interact with the
server.  This is available as a Ruby gem, requiring Ruby 1.9.3, and is usually
installed on developer workstations rather than the Razor server system.

Installing this is left as an exercise to the reader, but:

    puppet resource package name=razor-client provider=gem ensure=latest


## Parameters

* libarchive: set the package name for libarchive explicitly.
  - libarchive is require for ISO unpacking; if your system is not supported by autodetection you can set a manual package name instead.


## Contributors

A wide array of folks have contributed to the Razor module, including a pile
of hugely valuable external contributions.  The list was getting too long to maintain inline, but you can see the full list of contributors in the `CONTRIBUTORS` file.
