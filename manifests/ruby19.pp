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

  package { [ 'mongo', 'bson', 'bson_ext', 'rspec', 'syntax', 'uuid',
              'logger', 'extlib', 'json', 'colored', 'bluepill', 'autotest',
              'redcarpet', 'mocha', 'base62' ]:
    ensure   => present,
    provider => gem,
    require  => Exec['ruby_1.9.3_default'],
  }
}
