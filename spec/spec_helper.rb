require 'puppet'
require 'mocha'
require 'rspec'
require 'rspec-puppet'

def param_value(subject, type, title, param)
  subject.resource(type, title).send(:parameters)[param.to_sym]
end

Puppet.parse_config
puppet_module_path = Puppet[:modulepath]
fixture_path = File.expand_path(File.join(File.dirname(__FILE__), 'fixtures'))

RSpec.configure do |c|
  fixture_module_path = File.join(fixture_path, 'modules')
  c.module_path = [fixture_module_path, puppet_module_path].join(":")
  # Using an empty site.pp file to avoid: https://github.com/rodjek/rspec-puppet/issues/15
  c.manifest_dir = File.expand_path(File.join(File.dirname(__FILE__), 'fixtures/manifests'))
  # Use fixtures for config file mainly to support using our own hiera.yaml settings.
  # Pending: https://github.com/rodjek/rspec-puppet/pull/21
  # c.config   = File.expand_path(File.join(File.dirname(__FILE__), 'fixtures/puppet.conf'))
end
