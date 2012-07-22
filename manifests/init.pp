# Class: razor
#
# Parameters:
#
#   [*usename*]: daemon service account, default razor.
#   [*directory*]: installation directory, default /opt/razor.
#   [*ruby_version]: Ruby version, support 1.8.7 and 1.9.3, default 1.9.3.
#
# Actions:
#
#   Manages razor and it's dependencies ruby, nodejs, mongodb, tftp, and sudo.
#
# Requires:
#
#   * [apt module](https://github.com/puppetlabs/puppetlabs-apt)
#   * [Mongodb module](https://github.com/puppetlabs/puppetlabs-mongodb)
#   * [Node.js module](https://github.com/puppetlabs/puppetlabs-nodejs)
#   * [stdlib module](https://github.com/puppetlabs/puppetlabs-stdlib)
#   * [tftp module](https://github.com/puppetlabs/puppetlabs-tftp)
#   * [sudo module](https://github.com/saz/puppet-sudo)
#
# Usage:
#
#   class { 'razor':
#     directory    => '/usr/local/razor',
#   }
#
class razor (
  $username  = 'razor',
  $directory = '/opt/razor',
  $address   = $::ipaddress
){

  include sudo
  include 'razor::ruby'
  include 'razor::tftp'

  class { 'mongodb':
    enable_10gen => true,
  }

  Class['razor::ruby'] -> Class['razor']
  # The relationship is here so users can deploy tftp separately.
  Class['razor::tftp'] -> Class['razor']

  class { 'razor::nodejs':
    directory => $directory,
  }

  user { $username:
    ensure => present,
    gid    => $username,
    home   => $directory,
  }

  group { $username:
    ensure => present,
  }

  sudo::conf { 'razor':
    priority => 10,
    content  => "${username} ALL=(root) NOPASSWD: /bin/mount, /bin/umount\n",
  }

  if ! defined(Package['git']) {
    package { 'git':
      ensure => present,
      before => Vcsrepo[$directory],
    }
  }

  vcsrepo { $directory:
    ensure   => latest,
    provider => git,
    source   => 'http://github.com/puppetlabs/Razor.git',
  }

  file { $directory:
    ensure  => directory,
    mode    => '0755',
    owner   => $username,
    group   => $username,
    require => Vcsrepo[$directory],
  }

  file {'/etc/init.d/razor':
    ensure => present,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
    content => template("razor/razor.erb"),
    require  => [ File[$directory], Sudo::Conf['razor'] ],
  }

  service { 'razor':
    ensure    => running,
    hasstatus => true,
    require   => [ File['/etc/init.d/razor'], Class['mongodb'] ],
    subscribe => [ Class['razor::nodejs'], Vcsrepo[$directory] ],
  }
}
