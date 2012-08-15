rz_image { 'precise_image':
  ensure => absent,
}

rz_model { 'precise_model':
  ensure => absent,
  before => Rz_image['precise_image'],
}

rz_tag { 'virtual':
  ensure => absent,
}

rz_policy { 'precise_policy':
  ensure => absent,
  before => Rz_model['precise_model'],
}
