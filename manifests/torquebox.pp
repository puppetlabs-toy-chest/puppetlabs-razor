class razor::torquebox {
  $url  = 'http://torquebox.org/release/org/torquebox/torquebox-dist/3.0.1/torquebox-dist-3.0.1-bin.zip'
  $root = 'torquebox-3.0.1'
  $dest = '/opt/razor-torquebox'
  $user = 'razor-server'

  # Put the archive into place, if needed.
  exec { "install torquebox binary distribution to ${dest}":
    provider => shell,
    command  => template('razor/install-zip.sh.erb'),
    path     => '/bin:/usr/bin:/usr/local/bin:/opt/bin',
    creates  => "${dest}/jruby/bin/torquebox",
    require  => [Package[curl], Package[unzip]]
  } ->

  user { $user:
    ensure   => present,
    system   => true,           # system -- daemon -- user, please
    password => '*',            # no password logins, please
    home     => $dest,
    shell    => '/bin/bash',    # if it comes up, let's be common
    comment  => 'razor-server daemon user',
  } ->

  # Make sure that the deployment directory has appropriate ownership, so that
  # it can be written to as the razor user.  This is not as appropriate if we
  # deploy multiple applications in the one container, but for now we have a
  # dedicated install, so we go with that.
  file { "${dest}/jboss/standalone":
    recurse  => true,
    checksum => none,
    owner    => $user,
  } ->

  # Install an init script for the Razor torquebox install
  file { '/etc/init.d/razor-server':
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('razor/razor-server.init.erb')
  } ->

  file { '/var/log/razor-server':
    ensure => directory,
    owner  => $user,
    group  => 'root',
    mode   => '0755',
  } ->

  service { 'razor-server':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true
  }
}
