class razor::tftp {
  include tftp

  tftp::file { 'pxelinux.0':
    source => 'puppet:///modules/razor/pxelinux.0',
  }
  tftp::file { 'pxelinux.cfg':
    ensure => directory,
  }
  tftp::file { 'pxelinux.cfg/default':
    source => 'puppet:///modules/razor/default',
  }
  tftp::file { 'menu.c32':
    source => 'puppet:///modules/razor/menu.c32',
  }
  tftp::file { 'ipxe.iso':
    source => 'puppet:///modules/razor/ipxe.iso',
  }
  tftp::file { 'ipxe.lkrn':
    source => 'puppet:///modules/razor/ipxe.lkrn',
  }
  tftp::file { 'razor.ipxe':
    content => template('razor/razor.ipxe.erb'),
  }
}
