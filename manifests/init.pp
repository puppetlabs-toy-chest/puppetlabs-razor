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
class razor {
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
              'redcarpet', 'mocha' ]:
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

  include nodejs

  package { 'express':
    ensure   => present,
    provider => 'npm',
    require  => Class['nodejs'],
  }

  include mongodb
}
