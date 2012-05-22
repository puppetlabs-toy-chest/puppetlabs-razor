class razor::nodejs(
  $directory
) {
  include nodejs

  package { 'express':
    ensure   => present,
    provider => 'npm',
    require  => Package['npm'],
  }

  nodejs::npm { "${directory}:express":
    ensure   => present,
    require  => File[$directory],
  }

  nodejs::npm { "${directory}:mime":
    ensure   => present,
    require  => File[$directory],
  }
}
