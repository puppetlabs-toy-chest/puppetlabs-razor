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
  include ::ruby::dev

  if ! defined(Package['make']) {
    package { 'make':
      ensure => present,
    }
  }

  package { [
             'base62',
             'bson',
             'bson_ext',
             'colored',
             'daemons',
             'json',
             'logger',
             'macaddr',
             'mongo',
             'net-ssh',
             'require_all',
             'syntax',
             'uuid'
            ]:
    ensure   => present,
    provider => gem,
    require  => [ Class['::ruby'], Class['::ruby::dev'], Package['make'] ],
  }
}
