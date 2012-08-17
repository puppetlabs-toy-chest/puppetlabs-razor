# Example Openstack
rz_image { 'rz_mk_prod-image.0.9.0.4.iso':
  ensure  => present,
  type    => 'mk',
  source  => 'https://github.com/downloads/puppetlabs/Razor-Microkernel/rz_mk_prod-image.0.9.0.4.iso',
}

rz_image { 'Precise':
  ensure  => present,
  type    => 'os',
  version => '12.04',
  source  => '/opt/razor/ubuntu-12.04.1-server-amd64.iso',
}

razor::system { 'danscontroller':
  domain       => 'dmz25.lab',
  password     => 'test1234',
  instances    => 1,
  image        => 'Precise',
  tag_matcher  => [
    { 'key'     => 'macaddress_eth0',
      'compare' => 'equal',
      'value'   => '00:25:B5:00:05:CF',
      'inverse' => false,
    } ],
} -> 
razor::system { 'danscompute':
  domain       => 'dmz25.lab',
  password     => 'test1234',
  instances    => 1,
  image        => 'Precise',
  tag_matcher  => [
    { 'key'     => 'macaddress_eth0',
      'compare' => 'equal',
      'value'   => '00:25:B5:00:05:2F',
      'inverse' => false,
    } ],
} -> 

razor::system { 'compute':
  domain       => 'dmz25.lab',
  password     => 'test1234',
  instances    => 6,
  image        => 'Precise',
  tag_matcher  => [
    { 'key'     => 'productname',
      'compare' => 'equal',
      'value'   => 'N20-B6625-1',
      'inverse' => false,
    } ],
} ->

razor::system { 'control':
  domain       => 'dmz25.lab',
  password     => 'test1234',
  instances    => 6,
  image        => 'Precise',
  tag_matcher  => [
    { 'key'     => 'productname',
      'compare' => 'equal',
      'value'   => 'N20-B6620-1',
      'inverse' => false,
    } ],
}
