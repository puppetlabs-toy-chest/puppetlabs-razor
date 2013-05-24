# Class: razor::nodejs
#
# Actions:
#
#   Manages nodejs and npm package for razor.
#
class razor::nodejs(
  $directory
) {
  include nodejs
  case $lsbdistcodename {
    precise: { 
      $real_ensure = '3.2.2' 
    }
    default: { $real_ensure = "present" }
  }

  package { 'express':
    ensure   => $real_ensure,
    provider => 'npm',
    require  => Package['npm'],
  }

  nodejs::npm { "${directory}:express":
    ensure  => present,
    version => '2.5.11',
    require => File[$directory],
  }

  nodejs::npm { "${directory}:mime":
    ensure  => present,
    require => File[$directory],
  }
}
