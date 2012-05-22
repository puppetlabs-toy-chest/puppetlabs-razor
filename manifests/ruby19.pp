class razor::ruby19 {
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
      }
    }

    'Ubuntu': {
      exec { 'ruby_1.9.3_default':
        command   => 'update-alternatives --set ruby /usr/bin/ruby1.9.1 && update-alternatives --set gem /usr/bin/gem1.9.1',
        path      => $::path,
        unless    => 'ruby --version | grep "ruby 1.9"',
        provider  => 'shell',
        subscribe => Package['ruby1.9.3'],
      }
    }
  }

  # Need to specify macaddr 1.5.0 since 1.6.0 went backwards in dependencies.
  package { 'macaddr':
    ensure   => '1.5.0',
    provider => 'gem',
    require  => Exec['ruby_1.9.3_default'],
  }

  # Deploy uuid after macaddr so we don't pick up 1.6.0.
  package { 'uuid':
    ensure   => present,
    provider => 'gem',
    require  => Package['macaddr'],
  }

  package { [ 'autotest', 'base62', 'bluepill', 'bson', 'bson_ext', 
              'colored', 'extlib', 'json', 'logger', 'mocha', 'mongo',
              'net-ssh', 'redcarpet', 'require_all', 'rspec', 'syntax'
            ]:
    ensure   => present,
    provider => gem,
    require  => Exec['ruby_1.9.3_default'],
  }
}
