require 'fileutils'

Puppet::Type.type(:rz_broker).provide(:default) do

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
      brokers = query_razor.get_brokers
      brokers.each do |p|
        p[:ensure] = :present
        instances << new(p)
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

  def create
    @property_hash[:ensure] = :present

    broker = {
      'name'       => @resource[:name],
      'description' => @resource[:description],
      'servers'     => @resource[:servers],
      'plugin'      => @resource[:plugin],
    }

    Puppet.debug "razor -w broker add '#{broker.to_pson}'"
    command = ['razor', '-w', 'broker', 'add', "'#{broker.to_pson}'"].join(" ")
    execute(command, :combine => true)
  end

  def destroy
    @property_hash[:ensure] = :absent
    razor '-w', 'broker', 'remove', @property_hash[:uuid]
  end

  def exists?
    @property_hash[:ensure] == :present
  end
end
