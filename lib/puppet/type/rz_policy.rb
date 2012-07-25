require 'puppet/type'
require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.expand_path + 'puppet_x/puppet_labs/razor'

Puppet::Type.newtype(:rz_policy) do
  @doc = <<-EOT
    Manages razor policy.
EOT

  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of the policy."

    newvalues(/\w+/)
  end

  newproperty(:enabled) do
    newvalues(true, false)
    defaultto(true)
  end

  newproperty(:description) do
  end

  newproperty(:tags) do
  end

  newproperty(:broker) do
    defaultto('none')
  end

  newproperty(:maximum) do
    defaultto(0)
  end

  newproperty(:model) do
  end

  newparam(:template) do
  end

  newproperty(:priority) do

  end

  newproperty(:uuid) do
    desc "The image UUID. This property is not expected to be speciified by the user."
    validate do |value|
      raise Puppet::Error, "Do not specify UUID value."
    end
  end

  autorequire(:rz_model) do
    self[:model]
  end
end
