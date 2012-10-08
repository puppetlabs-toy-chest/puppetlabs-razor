# Deploying Ubuntu precise.
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

rz_image { 'rz_mk_prod-image.0.9.0.4.iso':
  ensure  => present,
  type    => 'mk',
  source  => 'https://github.com/downloads/puppetlabs/Razor-Microkernel/rz_mk_prod-image.0.9.0.4.iso',
}

rz_image { 'Precise':
  ensure  => present,
  type    => 'os',
  version => '12.04',
  source  => 'http://releases.ubuntu.com/12.04/ubuntu-12.04.1-server-amd64.iso',
}

# Example for how to specify per host policy based on macaddress.
razor::system { 'demo':
  domain       => 'dmz25.lab',
  password     => 'test1234',
  instances    => 1,
  image        => 'Precise',
  tag_matcher  => [
    { 'key'     => 'macaddress_eth0',
      'compare' => 'equal',
      'value'   => '00:25:B5:00:05:BF',
      'inverse' => false,
    } ],
}
