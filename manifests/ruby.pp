class razor::ruby(
  $version = '1.9.3',
){
  anchor { 'ruby': }

  if $version == '1.8.7' {
    package { ['ruby', 'rubygems']:
      ensure => present,
      before => Anchor['ruby'],
    }
  } elsif $version == '1.9.3' {
    package { 'ruby1.9.3':
      ensure => present,
    }

    case $::operatingsystem {
      'Debian': {
        package { 'ruby-switch':
          ensure => present,
        }

        # The command passes --set 1.9.1, but actually sets to 1.9.3:
        exec { 'ruby_1.9.3_default':
          command     => 'ruby-switch --set ruby1.9.1',
          path        => $::path,
          refreshonly => true,
          subscribe   => Package['ruby1.9.3', 'ruby-switch'],
          before      => Anchor['ruby'],
        }
      }

      'Ubuntu': {
        exec { 'ruby_1.9.3_default':
          command   => 'update-alternatives --set ruby /usr/bin/ruby1.9.1 && update-alternatives --set gem /usr/bin/gem1.9.1',
          path      => $::path,
          unless    => 'ruby --version | grep "ruby 1.9"',
          provider  => 'shell',
          subscribe => Package['ruby1.9.3'],
          before    => Anchor['ruby'],
        }
      }
    }
  } else {
    fail("Does not support Ruby ${version} on platform ${::operatingsystem}")
  }

  # Need to specify macaddr 1.5.0 since 1.6.0 went backwards in dependencies.
  package { 'macaddr':
    ensure   => '1.5.0',
    provider => 'gem',
    require  => Anchor['ruby'],
  }

  # Deploy uuid after macaddr so we don't pick up 1.6.0.
  package { 'uuid':
    ensure   => present,
    provider => 'gem',
    require  => Anchor['ruby'],
  }

  if ! defined(Package['make']) {
    package { 'make':
      ensure => present,
    }
  }

  package { [ 'autotest', 'base62', 'bson', 'bson_ext', 'colored',
              'daemons', 'json', 'logger', 'mocha', 'mongo',
              'net-ssh', 'require_all', 'syntax'
            ]:
    ensure   => present,
    provider => gem,
    require  => [ Anchor['ruby'], Package['make'] ],
  }
}
