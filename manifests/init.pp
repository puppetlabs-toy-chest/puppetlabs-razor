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
  $username     = 'razor',
  $directory    = '/opt/razor',
  $ruby_version = '1.9.3'
){

  include mongodb
  include sudo
  include 'razor::tftp'

  # The relationship is here so users can deploy tftp separately.
  Class['razor::tftp'] -> Class['razor']

  class { 'razor::ruby':
    version => $ruby_version,
    before  => Class['razor'],
  }

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
    source   => 'git://github.com/puppetlabs/Razor.git',
  }

  file { $directory:
    ensure  => directory,
    mode    => '0755',
    owner   => $username,
    group   => $username,
    require => Vcsrepo[$directory],
  }

  service { 'razor':
    ensure    => running,
    hasstatus => true,
    status    => "${directory}/bin/razor_daemon.rb",
    require   => [ Class['mongodb'], File[$directory], Sudo::Conf['razor'] ],
  }

}
