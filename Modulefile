# -*- ruby -*-
name         'puppetlabs-razor'
source       'git@github.com:puppetlabs/puppetlabs-razor.git'
author       'Puppet Labs'
license      'Apache 2.0'
summary      'Razor puppet module'
description  'Razor provisioning system puppet installation module'
project_page 'https://github.com/puppetlabs/puppetlabs-razor'

# Set up our git directory, and figure out where the module is, so that
# we can run a successful build outside the working directory; this happens
# when puppet-librarian tries to build from git, at least.
moduledir = File.dirname(__FILE__)
ENV['GIT_DIR'] = moduledir + '/.git'

# Grab the version number from git, and bump up the tiny version number if we
# have a postfix string, since Puppet only supports SemVer 1.0.0, which
# doesn't have anything but "version" and "pre-release of version".
#
# Technically this isn't accurately reflecting the real next release number,
# but whatever - it will do for now.
git_version = %x{#{moduledir}/bin/get-version-from-git}.chomp
unless $?.success? and git_version =~ /^\d+\.\d+\.\d+/
  raise "Unable to determine version using git: #{$?} => #{git_version.inspect}"
end
version    git_version

## Add dependencies, if any:
dependency 'puppetlabs/stdlib',  '>= 2.0.0'
dependency 'puppetlabs/mongodb', '>= 0.1.0'
dependency 'puppetlabs/nodejs',  '>= 0.1.1'
dependency 'puppetlabs/ruby',    '>= 0.0.2'
dependency 'puppetlabs/tftp',    '>= 0.2.0'
dependency 'puppetlabs/vcsrepo', '>= 0.0.5'
dependency 'saz/sudo',           '>= 2.0.0'


# Generate the changelog file
system("'#{moduledir}'/bin/git-log-to-changelog > '#{moduledir}'/CHANGELOG")
$? == 0 or fail "changelog generation #{$?}!"

