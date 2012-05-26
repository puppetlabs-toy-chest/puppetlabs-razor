class razor::ruby18 {
  package { 'ruby':
    ensure => present,
  }

  # Need to specify macaddr 1.5.0 since 1.6.0 went backwards in dependencies.
  package { 'macaddr':
    ensure   => '1.5.0',
    provider => 'gem',
  }

  # Deploy uuid after macaddr so we don't pick up 1.6.0.
  package { 'uuid':
    ensure   => present,
    provider => 'gem',
    require  => Package['macaddr'],
  }

  package { 'make':
    ensure => present,
  }

  package { [ 'autotest', 'base62', 'bluepill', 'bson', 'bson_ext',
              'colored', 'extlib', 'json', 'logger', 'mocha', 'mongo',
              'net-ssh', 'redcarpet', 'require_all', 'rspec', 'syntax'
            ]:
    ensure   => present,
    provider => gem,
    require  => [ Exec['ruby_1.9.3_default'], Package['make'] ],
  }
}
