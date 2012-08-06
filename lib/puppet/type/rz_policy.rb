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
    desc "The policy description."
  end

  newproperty(:tags) do
    desc "The policy tags."
    munge do |value|
      [ value ] unless value.is_a? Array
    end
  end

  newproperty(:broker) do
    desc "The policy broker name."
    defaultto('none')
  end

  newproperty(:maximum) do
    desc "The policy maximum deployment instances."
    defaultto(0)
  end

  newproperty(:model) do
    desc "The policy deployment model."
    newvalues(/\w+/)
  end

  newparam(:template) do
    desc "The policy template name."
    newvalues(/\w+/)
  end

  newproperty(:priority) do
    desc "The policy priority."
  end

  newproperty(:uuid) do
    desc "The policy UUID. This property is not expected to be speciified by the user."
    validate do |value|
      raise Puppet::Error, "Do not specify UUID value."
    end
  end

  autorequire(:rz_model) do
    self[:model]
  end
end
