# Example for how to specify per host policy based on macaddress.

define system (
  $macaddress,
  $hostname       = $name, # The actual model is actually prefix, a model with hostname is required.
  $domainname     = 'puppetlabs.lan',
  $rootpassword   = 'puppet',
  $image          = 'precise',
  $model_template = 'ubuntu_precise',
) {

  rz_model { $name:
    ensure      => present,
    image       => $image,
    metadata    => { 'domainname'      => $domainname,
                     'hostname_prefix' => $hostname,
                     'rootpassword'    => $rootpassword, },
    template    => $model_template,
  }

  rz_tag { $name:
    tag_label   => $name,
    tag_matcher => [ { 'key'     => 'macaddress',
                       'compare' => 'equal',
                       'value'   => $macaddress,
                       'inverse' => false,
                     } ],
  }

  rz_policy { $name:
    ensure  => 'present',
    broker  => 'none',
    model   => $name,
    enabled => 'true',
    tags    => [$name],
    template => 'linux_deploy',
    maximum => 1,
  }
}

rz_image { 'UbuntuPrecise':
  ensure => present,
  type    => 'os',
  version => '12.04',
  source  => '/mnt/nfs/ubuntu-12.04-server-amd64.iso',
}

system { 'database':
  macaddress   => '00:0c:29:6e:e7:83',
  rootpassword => 'dba_only_passwd',
  image        => 'UbuntuPrecise',
}

system { 'webserver':
  macaddress => '86:36:30:54:AD:A6',
  image      => 'UbuntuPrecise',
}
