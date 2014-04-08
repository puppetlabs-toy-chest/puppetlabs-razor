require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'

# Customize lint option
task :lint do
  PuppetLint.configuration.send("disable_80chars")
  PuppetLint.configuration.send("disable_class_parameter_defaults")
  PuppetLint.configuration.ignore_paths = ["spec/**/*.pp", "pkg/**/*.pp"]
end
