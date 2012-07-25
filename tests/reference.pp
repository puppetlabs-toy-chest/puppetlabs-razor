rz_image { 'precise_image':
  ensure => present,
  type    => 'os',
  version => '12.04',
  source  => '/mnt/nfs/ubuntu-12.04-server-amd64.iso',
}

rz_model { 'precise_model':
  ensure      => present,
  description => 'Ubuntu Precise Model',
  image       => 'precise_image',
  metadata    => {'domainname' => 'puppetlabs.lan', 'hostname_prefix' => 'openstack', 'root_password' => 'puppet'},
  template    => 'ubuntu_precise',
}

rz_policy { 'precise_policy':
  ensure  => 'present',
  broker  => 'none',
  model   => 'precise_model',
  enabled => 'true',
  tags    => ['virtual'],
  template => 'linux_deploy',
  maximum => 1,
}
