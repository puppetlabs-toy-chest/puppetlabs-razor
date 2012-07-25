require 'puppet/type'
require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.expand_path + 'puppet_x/puppet_labs/razor'

Puppet::Type.newtype(:rz_model) do
  @doc = <<-EOT
    Manages razor models.
EOT

  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of the model."

    newvalues(/\w+/)
  end

  newproperty(:description) do
    desc "The model description"

    newvalues(/\w+/)
  end

  newproperty(:template) do
    desc "The model template"

    newvalues(/\w+/)
  end

  newproperty(:uuid) do
    desc "The model UUID (do not set)."
    validate do |value|
      raise Puppet::Error, "Do not specify UUID value."
    end
  end

  newproperty(:image) do
    desc "The image name"
  end

  newproperty(:version) do
  end

  newparam(:metadata) do
    validate do |value|
      raise Puppet::Error, "Metadata should be a hash" unless value.is_a? Hash
    end
  end

  autorequire(:rz_image) do
    self[:image]
  end
end
