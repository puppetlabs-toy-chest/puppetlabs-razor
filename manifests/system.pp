# Deploying specific systems. Only tested with Ubuntu precise.
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

