# Class: razor
#
# Parameters:
#
#   [*source*]: `tar`, `package`, or `git`: install from the tarball, OS packages, or git HEAD?; `tar` is the default, for now.
#   [*usename*]: daemon service account, default razor.
#   [*directory*]: installation directory, default /opt/razor.
#   [*address*]: razor.ipxe chain address, and razor service listen address,
#                default: facter ipaddress.
#   [*persist_host*]: ip address of the mongodb server.
#   [*mk_checkin_interval*]: mk checkin interval.
#   [*mk_name*]: Razor tinycore linux mk name.
#   [*mk_source*]: Razor tinycore linux mk iso file source (local or http).
#   [*rubygems_update*]: Update rubygems, default is **OFF**.
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
  $source              = 'tar',
  $username            = 'razor',
  $directory           = '/opt/razor',
  $address             = $::ipaddress,
  $persist_host        = '127.0.0.1',
  $mk_checkin_interval = '60',
  $mk_name             = 'razor-microkernel-latest.iso',
  $mk_source           = 'https://downloads.puppetlabs.com/razor/iso/prod/razor-microkernel-latest.iso',
  $rubygems_update     = false
) {
  # The version of Razor to install; this is not exposed for the user to
  # modify or change.  Feel free to edit the module yourself, though, if you
  # want; really, we just don't want to make it easy to point the gun of "old
  # module, new code" at your own foot. --daniel 2013-04-09
  $version = '0.9.0'

  include sudo
  include 'razor::tftp'

  class {
    'razor::ruby':
      rubygems_update => $rubygems_update;
    'mongodb':
      enable_10gen => true;
  }

  Class['razor::ruby'] -> Class['razor']
  # The relationship is here so users can deploy tftp separately.
  Class['razor::tftp'] -> Class['razor']

  file { $directory:
    ensure  => directory,
    mode    => '0755',
    owner   => $username,
    group   => $username,
    before  => Class['razor::nodejs']
  }

  class { 'razor::nodejs':
    directory => $directory
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

  if $source == 'package' {
    package { "puppet-razor": ensure => $version }

    Package["puppet-razor"] -> File[$directory]
    Package["puppet-razor"] -> Service[razor]
    Package["puppet-razor"] -> File["/usr/bin/razor"]
    Package["puppet-razor"] -> File["$directory/conf/razor_server.conf"]
  } elsif $source == 'tar' {
    exec { "refuse to unpack tarball over git install":
      provider => shell,
      command  => "! test -d '${directory}'/.git"
    }

    exec { "unpack razor ${version} from tarball":
      provider => shell,
      cwd      => "/var/tmp",
      command  => "curl http://downloads.puppetlabs.com/razor/puppet-razor-${version}.tar.gz | tar zx",
      creates  => "/var/tmp/puppet-razor-${version}",
      require  => [Package[curl], Exec["refuse to unpack tarball over git install"]]
    }

    exec { "install razor ${version} into ${directory}":
      provider => shell,
      cwd      => $directory,
      command  => "(cd /var/tmp/puppet-razor-${version} && tar c .) | tar x",
      unless   => "${directory}/bin/razor --version | grep -q '${version}\$'",
      require  => Exec["unpack razor ${version} from tarball"]
    }

    Exec["install razor ${version} into ${directory}"] -> Service[razor]
    Exec["install razor ${version} into ${directory}"] -> File["/usr/bin/razor"]
    Exec["install razor ${version} into ${directory}"] -> File["${directory}/conf/razor_server.conf"]
  } elsif $source == 'git' {
    if ! defined(Package['git']) {
      package { 'git': ensure => present }
    }

    vcsrepo { $directory:
      ensure   => latest,
      provider => git,
      source   => 'http://github.com/puppetlabs/Razor.git',
      revision => 'master',
      require  => Package['git'],
    }

    Vcsrepo[$directory] -> File[$directory]
    Vcsrepo[$directory] -> Service[razor]
    Vcsrepo[$directory] -> File["/usr/bin/razor"]
    Vcsrepo[$directory] -> File["$directory/conf/razor_server.conf"]
  } else {
    fail("unknown razor project source '${source}'")
  }

  service { 'razor':
    ensure    => running,
    provider  => base,
    hasstatus => true,
    status    => "${directory}/bin/razor_daemon.rb status",
    start     => "${directory}/bin/razor_daemon.rb start",
    stop      => "${directory}/bin/razor_daemon.rb stop",
    require   => [
      Class['mongodb'],
      File[$directory],
      Sudo::Conf['razor']
    ],
    subscribe => [
      Class['razor::nodejs']
    ],
  }

  file { '/usr/bin/razor':
    ensure  => file,
    owner   => '0',
    group   => '0',
    mode    => '0755',
    content => template('razor/razor.erb')
  }

  if ! defined(Package['curl']) {
    package { 'curl':
      ensure => present,
    }
  }

  rz_image { $mk_name:
    ensure  => present,
    type    => 'mk',
    source  => "${directory}/${mk_name}",
    url     => $mk_source,
    require => [
      File['/usr/bin/razor'],
      Package['curl'],
      Service['razor']
    ],
  }

  file { "$directory/conf/razor_server.conf":
    ensure  => file,
    content => template('razor/razor_server.erb'),
    notify  => Service['razor'],
  }

}
