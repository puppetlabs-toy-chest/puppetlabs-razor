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

  include mongodb
  include sudo
  include 'razor::nodejs'
  include 'razor::tftp'

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

  vcsrepo { $directory:
    ensure   => latest,
    provider => git,
    source   => 'git://github.com/puppetlabs/Razor.git',
  }

  file { $directory:
    ensure  => directory,
    mode    => '0755',
    owner   => $username,
    group   => $username,
    require => Vcsrepo[$directory],
  }

}
