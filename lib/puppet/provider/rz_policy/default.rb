require 'fileutils'

Puppet::Type.type(:rz_policy).provide(:default) do

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
      policies = query_razor.get_policies
      policies.each do |p|
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
    uuid = query_razor.get_model_uuid(@resource[:model])

    policy = {
      'template'    => @resource[:template],
      'label'       => @resource[:name],
      'model_uuid'  => uuid,
      'broker_uuid' => @resource[:broker],
      'enabled'     => @resource[:enabled],
      'tags'        => @resource[:tags],
      'maximum'     => @resource[:maximum] || 0,
    }

    policy['broker_uuid'] = @resource[:broker] if @resource[:broker] != 'none'

    Puppet.debug "razor -w model add '#{policy.to_pson}'"
    command = ['razor', '-w', 'policy', 'add', "'#{policy.to_pson}'"].join(" ")
    execute(command, :combine => true)
  end

  def destroy
    @property_hash[:ensure] = :absent
    razor '-w', 'policy', 'remove', @property_hash[:uuid]
  end

  def exists?
    @property_hash[:ensure] == :present
  end
end
