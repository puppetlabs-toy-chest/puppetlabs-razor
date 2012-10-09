# Examples for downloading/importing razor mk image:
rz_image { 'rz_mk_prod-image.0.9.0.4.iso':
  ensure  => present,
  type    => 'mk',
  source  => 'https://github.com/downloads/puppetlabs/Razor-Microkernel/rz_mk_prod-image.0.9.0.4.iso',
}

rz_image { 'rz_mk_dev-image.0.9.1.4.iso':
  ensure  => present,
  type    => 'mk',
  source  => 'https://github.com/downloads/puppetlabs/Razor-Microkernel/rz_mk_dev-image.0.9.1.4.iso',
}
