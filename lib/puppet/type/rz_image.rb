require 'puppet/type'
require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.expand_path + 'puppet_x/puppet_labs/razor'

Puppet::Type.newtype(:rz_image) do
  @doc = <<-EOT
    Manages razor images.
EOT

  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of the operating system."
    newvalues(/\w+/)
  end

  newparam(:source) do
    desc "The image source, can be either local absolute path or remote http(s) source."
    validate do |value|
      raise Puppet::Error, "only support local path or http(s) source" unless value =~ /^(\/|http:|https:)/
    end
  end

  newproperty(:version) do
    desc "The image version. The value is automatically detected for mk and esx."
    newvalues(/[A-Za-z0-9]/)
  end

  newproperty(:type) do
    desc "The image type, currently support mk, os, esxi"
    newvalues('mk', 'os', 'esxi')
    defaultto('mk')
    validate do |value|
      raise Puppet::Error, "Require image version" if value == 'os' and @resource[:version].nil?
    end
  end

  newproperty(:uuid) do
    desc "The image UUID. This property is not expected to be specified by the user."
    validate do |value|
      raise Puppet::Error, "Do not specify UUID value."
    end
  end
end
