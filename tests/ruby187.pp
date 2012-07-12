class { 'sudo':
  config_file_replace => false,
}
class { 'razor':
  ruby_version => '1.8.7',
}
