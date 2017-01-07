class razor::tftp(
  $server
) {
  include ::tftp

  ::tftp::file { 'undionly.kpxe': }

  ::tftp::file { 'bootstrap.ipxe':
    content => template('razor/bootstrap.ipxe.erb')
  }
}
