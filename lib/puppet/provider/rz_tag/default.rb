require 'fileutils'

Puppet::Type.type(:rz_tag).provide(:default) do

  commands :razor => 'razor'

  def self.query_razor
    PuppetX::PuppetLabs::Razor.new(method(:razor))
  end

  def query_razor
    self.class.query_razor
  end

  mk_resource_methods

  def self.instances
    instances = Array.new
    begin
      tags = query_razor.get_tags
      tags.each do |t|
        t[:ensure] = :present
        instances << new(t)
      end
    rescue
      instances = {}
    end

    instances
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  # Clear out the cached values.
  def flush
    @property_hash.clear
  end

  def tag_matcher=(value)
    uuids = @property_hash[:tag_matcher].collect{|m| m[:uuid] }

    # It's inefficient but safer to add new matchers and remove all existing matchers.
    value.each do |m|
      matcher = {
      # :tag_rule_uuid => @property_hash[:uuid],
        :key           => m['key'],
        :value         => m['value'],
        :compare       => m['compare'],
        :inverse       => m['inverse'],
      }
      command = ['razor', '-w', 'tag', @property_hash[:uuid], 'matcher', 'add', "'#{matcher.to_pson}'"].join(" ")
      results = execute(command, :combine => true)
      Puppet.debug(results)
    end

    uuids.each do |i|
      command = ['razor', '-w', 'tag', @property_hash[:uuid], 'matcher', 'remove', i].join(" ")
      results = execute(command, :combine => true)
      Puppet.debug(results)
    end
  end

  def create
    @property_hash[:ensure] = :present

    tag = {
      'name'         => @resource[:name],
      'tag'          => @resource[:tag_label],
    }

    Puppet.debug "razor -w tag add '#{tag.to_pson}'"
    tag_uuid = query_razor.add_tag(tag.to_pson)

    @resource[:tag_matcher].each do |m|
      matcher = {
      # :tag_rule_uuid => tag_uuid,
        :key           => m['key'],
        :value         => m['value'],
        :compare       => m['compare'],
        :inverse       => m['inverse'],
      }
      command = ['razor', '-w', 'tag', tag_uuid, 'matcher', 'add', "'#{matcher.to_pson}'"].join(" ")
      results = execute(command, :combine => true)
      Puppet.debug(results)
    end
  end

  def destroy
    @property_hash[:ensure] = :absent
    @property_hash[:tag_matcher].each do |m|
      razor '-w', 'tag', @property_hash[:uuid], 'matcher', 'remove', m[:uuid]
    end
    razor '-w', 'tag', 'remove', @property_hash[:uuid]
  end

  def exists?
    @property_hash[:ensure] == :present
  end
end
