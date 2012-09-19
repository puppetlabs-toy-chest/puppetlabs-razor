$image          = 'precise'
$domainname     = 'puppetlabs.lan'
$rootpassword   = 'puppet'
$model_template = 'ubuntu_precise'

rz_image { $image:
  ensure => present,
  type    => 'os',
  version => '12.04',
  source  => '/mnt/nfs/ubuntu-12.04-server-amd64.iso',
}

rz_model { 'controller':
  ensure      => present,
  image       => $image,
  metadata    => { 'domainname'      => $domainname,
                   'hostname_prefix' => 'controller',
                   'rootpassword'    => $rootpassword, },
  template    => $model_template,
}

rz_model { 'compute':
  ensure      => present,
  image       => 'UbuntuPrecise',
  metadata    => { 'domainname'      => $domainname,
                   'hostname_prefix' => 'compute',
                   'rootpassword'    => $rootpassword, },
  template    => $model_template,
}

rz_model { 'storage':
  ensure      => present,
  image       => 'UbuntuPrecise',
  metadata    => { 'domainname'      => $domainname,
                   'hostname_prefix' => 'storage',
                   'rootpassword'    => $rootpassword, },
  template    => $model_template,
}

rz_tag { 'storage':
  tag_label   => $name,
  tag_matcher => [ { 'key'     => 'mk_hw_disk_count',
                     'compare' => 'equal',
                     'value'   => 6,
                     'inverse' => false,
                   } ],
}

rz_tag { 'physical':
  tag_label   => $name,
  tag_matcher => [ { 'key'     => 'is_virtual',
                     'compare' => 'equal',
                     'value'   => 'false',
                     'inverse' => false,
                   } ],
}

rz_policy { 'controller':
  ensure  => 'present',
  broker  => 'none',
  model   => 'controller',
  enabled => 'true',
  tags    => ['physical'],
  template => 'linux_deploy',
  maximum => 1,
}

rz_policy { 'compute':
  ensure  => 'present',
  broker  => 'none',
  model   => 'controller',
  enabled => 'true',
  tags    => ['physical'],
  template => 'linux_deploy',
  maximum => 0,
}

rz_policy { 'storage':
  ensure  => 'present',
  broker  => 'none',
  model   => 'storage',
  enabled => 'true',
  tags    => ['physical','storage'],
  template => 'linux_deploy',
  maximum => 0,
}
