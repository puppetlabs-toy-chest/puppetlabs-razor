# Deploying Ubuntu Precise
define razor::system (
  $hostprefix      = $name,
  $domain,
  $password,
  $tag_matcher     = [],
  $broker          = 'none',
  $instances       = '0',
  $image           = 'precise',
  $policy_template = 'linux_deploy',
  $model_template  = 'ubuntu_precise',
) {

  rz_model { $name:
    ensure    => present,
    image     => $image,
    metadata  => { 'domainname'      => $domain,
                   'hostname_prefix' => $hostprefix,
                   'root_password'    => $password, },
    template  => $model_template,
  }

  rz_tag { $name:
    tag_label   => $name,
    tag_matcher => $tag_matcher,
  }

  rz_policy { $name:
    ensure  => 'present',
    broker  => $broker,
    model   => $name,
    enabled => 'true',
    tags    => [$name],
    template => 'linux_deploy',
    maximum => $instances,
  }
}

# Example Openstack Desployment on UCS hardware.
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
