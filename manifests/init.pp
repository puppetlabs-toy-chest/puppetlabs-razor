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
  include 'razor::tftp'
  include 'razor::ruby19'

  Class['razor::tftp'] -> Class['razor']
  Class['razor::ruby19'] -> Class['razor']

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
