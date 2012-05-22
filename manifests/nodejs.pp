class razor::nodejs {
  include nodejs
  Class['razor::nodejs'] -> Class['razor']

  package { 'express':
    ensure   => present,
    provider => 'npm',
    require  => Class['nodejs'],
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
