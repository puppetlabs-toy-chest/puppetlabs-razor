require 'puppet/type'
require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.expand_path + 'puppet_x/puppet_labs/razor'

Puppet::Type.newtype(:rz_tag) do
  @doc = <<-EOT
    Manages razor tags.
EOT

  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of the operating system."
    newvalues(/\w+/)
  end

  newproperty(:tag_label) do
    desc "The razor tag. (do not use puppet metaparameter tag)"
    newvalues(/[A-Za-z0-9]/)
  end

  newproperty(:tag_matcher, :array_matching => :all) do
    desc "The tag_matcher rules."

    validate do |value|
      value.each do |m|
        raise Puppet::Error, "Mush provide individual tag_matcher as Hash values. " unless value.is_a? Hash
      end

      matcher_attrib = %w[key value inverse compare]
      value.keys.each do |k|
        raise Puppet::Error, "Does not support tag_matcher key: #{k}" unless matcher_attrib.include? k
      end
    end

    munge do |value|
      value['inverse'] ||= false
      value['compare'] ||= 'equal'
      value
    end

    def insync?(is)
      # Comparison of Array of Hashes
      return false unless is.class == Array and should.class == Array

      sys = is.collect do |i|
        i[:key] ||= ''
        i[:value] ||= ''
        i[:compare] ||= ''
        i[:inverse] ||= ''
        i[:key]+i[:compare]+i[:value]+i[:inverse]
      end

      user = should.collect do |i|
        i['key'] ||= ''
        i['value'] ||= ''
        i['compare'] ||= 'equal'
        i['inverse'] ||= 'false'
        i['key']+i['compare']+i['value']+i['inverse']
      end

      if (sys - user).size == 0 and (user - sys).size == 0
        true
      else
        false
      end
    end

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end
  end

  newproperty(:uuid) do
    desc "The tag UUID. This property is not expected to be specified by the user."
    validate do |value|
      raise Puppet::Error, "Do not specify UUID value."
    end
  end
end
