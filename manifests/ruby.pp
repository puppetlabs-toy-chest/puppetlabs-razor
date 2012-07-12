# Class: razor::ruby
#
# Parameters:
#
#   [*version*]: Ruby version.
#
# Actions:
#
#   Manage ruby for razor.
#
# Usage:
#   include 'razor::ruby'
class razor::ruby {

  include ::ruby

  if ! defined(Package['make']) {
    package { 'make':
      ensure => present,
    }
  }

  package { [ 'autotest', 'base62', 'bson', 'bson_ext', 'colored',
              'daemons', 'json', 'logger', 'macaddr', 'mocha', 'mongo',
              'net-ssh', 'require_all', 'syntax', 'uuid'
            ]:
    ensure   => present,
    provider => gem,
    require  => [ Class['::ruby'], Package['make'] ],
  }
}
