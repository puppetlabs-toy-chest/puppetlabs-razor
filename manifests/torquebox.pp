class razor::torquebox {
  $url  = 'http://torquebox.org/release/org/torquebox/torquebox-dist/3.0.0/torquebox-dist-3.0.0-bin.zip'
  $root = 'torquebox-3.0.0'
  $dest = '/opt/razor-torquebox'
  $user = 'razor-server'

  # Put the archive into place, if needed.
  exec { "install torquebox binary distribution to ${dest}":
    provider => shell,
    command  => template('razor/install-zip.sh.erb'),
    path     => '/bin:/usr/bin:/usr/local/bin:/opt/bin',
    creates  => "${dest}/jruby/bin/torquebox",
    require  => [Package[curl], Package[unzip]]
  }

  user { $user:
    ensure   => present,
    system   => true,           # system -- daemon -- user, please
    password => '*',            # no password logins, please
    home     => $dest,
    shell    => '/bin/bash',    # if it comes up, let's be common
    comment  => "razor-server daemon user",
  }

  # Install an init script for the Razor torquebox install
  file { "/etc/init.d/razor-server":
    owner   => root, group => root, mode => 0755,
    content => template('razor/razor-server.init.erb')
  } ->

  file { "/var/log/razor-server":
    ensure => directory, owner => $user, group => 'root', mode => 0755
  } ->

  file { "/opt/razor-torquebox/jboss/standalone":
    ensure  => directory, owner => $user, group => $user,
    recurse => true, checksum => none,
    require => Exec["install torquebox binary distribution to ${dest}"]
  } ->

  service { "razor-server":
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true
  }
}
