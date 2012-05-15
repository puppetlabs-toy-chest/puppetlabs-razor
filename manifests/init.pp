# Class: razor
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Usage:
#
class razor (
  $username  = 'razor',
  $directory = '/opt/razor'
){
  package { 'ruby1.9.3':
    ensure => present,
  }

  package { 'ruby-switch':
    ensure => present,
  }

  # The command is set 1.9.1, but actually sets to 1.9.3:
  exec { 'ruby_1.9.3_default':
    command     => 'ruby-switch --set ruby1.9.1',
    path        => $::path,
    refreshonly => true,
    subscribe   => Package['ruby1.9.3', 'ruby-switch'],
  }

  package { [ 'mongo', 'bson', 'bson_ext', 'rspec', 'syntax', 'uuid',
              'logger', 'extlib', 'json', 'colored', 'bluepill', 'autotest',
              'redcarpet', 'mocha', 'base62' ]:
    ensure   => present,
    provider => gem,
    require  => Exec['ruby_1.9.3_default'],
  }

  include tftp

  tftp::file { 'pxelinux.0':
    source => 'puppet:///modules/razor/pxelinux.0',
  }
  tftp::file { 'pxelinux.cfg':
    ensure => directory,
  }
  tftp::file { 'pxelinux.cfg/default':
    source => 'puppet:///modules/razor/default',
  }
  tftp::file { 'menu.c32':
    source => 'puppet:///modules/razor/menu.c32',
  }
  tftp::file { 'ipxe.iso':
    source => 'puppet:///modules/razor/ipxe.iso',
  }
  tftp::file { 'ipxe.lkrn':
    source => 'puppet:///modules/razor/ipxe.lkrn',
  }
  tftp::file { 'razor.ipxe':
    content => template('razor/razor.ipxe.erb'),
  }

  user { $username:
    ensure => present,
    gid    => $username,
    home   => $directory,
  }

  group { $username:
    ensure => present,
  }

  include sudo

  sudo::conf { 'razor':
    priority => 10,
    content  => "${username} ALL=(root) NOPASSWD: /bin/mount, /bin/umount\n",
  }

  include nodejs

  package { 'express':
    ensure   => present,
    provider => 'npm',
    require  => Class['nodejs'],
  }

  file { $directory:
    ensure  => directory,
    mode    => '0755',
    owner   => $username,
    group   => $username,
    require => Vcsrepo[$directory],
  }

  vcsrepo { $directory:
    ensure   => latest,
    provider => git,
    source   => 'git://github.com/puppetlabs/Razor.git',
  }

  nodejs::npm { "${directory}:express":
    ensure   => present,
    require  => File[$directory],
  }

  nodejs::npm { "${directory}:mime":
    ensure   => present,
    require  => File[$directory],
  }

  include mongodb
}
