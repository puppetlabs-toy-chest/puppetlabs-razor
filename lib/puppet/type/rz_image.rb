require 'puppet/type'
require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.expand_path + 'puppet_x/puppet_labs/razor'

Puppet::Type.newtype(:rz_image) do
  @doc = <<-EOT
    Manages razor images.
EOT

  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of the os."

    validate do |path|
    end
  end

  newparam(:source) do
    desc "The image source, can be either local absolute path or remote http(s) source."
    validate do |value|
      raise Puppet::Error, "only support local path or http(s) source" unless value =~ /^(\/|http:|https:)/
    end
  end

  newproperty(:type) do
    newvalues('mk', 'os', 'esxi')
    defaultto('mk')
  end

  newproperty(:version) do

  end

  newproperty(:uuid) do
    desc "The image UUID. This property is not expected to be speciified by the user."
    validate do |value|
      raise Puppet::Error, "Do not specify UUID value."
    end
  end
end
