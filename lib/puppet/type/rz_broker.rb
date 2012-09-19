require 'puppet/type'
require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.expand_path + 'puppet_x/puppet_labs/razor'

Puppet::Type.newtype(:rz_broker) do
  @doc = <<-EOT
    Manages razor broker.
EOT

  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of the broker."
    newvalues(/\w+/)
  end

  newproperty(:plugin) do
    desc "The broker plugin."
    newvalues(/\w+/)
  end

  newproperty(:servers, :array_matching => :all) do
    desc "The broker servers."
    munge do |value|
      [ value ] unless value.is_a? Array
    end
  end

  newproperty(:uuid) do
    desc "The broker UUID. This property is not expected to be speciified by the user."
    validate do |value|
      raise Puppet::Error, "Do not specify UUID value."
    end
  end
end
