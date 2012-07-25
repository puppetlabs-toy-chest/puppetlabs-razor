require 'fileutils'

Puppet::Type.type(:rz_model).provide(:default) do

  commands :razor => 'razor'

  def self.query_razor
    PuppetX::PuppetLabs::Razor.new(method(:razor))
  end

  def query_razor
    self.class.query_razor
  end

  mk_resource_methods

  def self.instances
    razor_models = Array.new
    begin
      models = query_razor.get_models
      models.each do |m|
        m[:ensure] = :present
        m[:name]   = m[:name] || m[:isoname]
        razor_models << new(m)
      end
    rescue
      razor_models = {}
    end

    razor_models
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
    uuid = query_razor.get_image_uuid(@resource[:image])
    require 'pp'

    model = {
      'template'          => @resource[:template],
      'label'             => @resource[:name],
      'image_uuid'        => uuid,
      'req_metadata_hash' => @resource[:metadata],
    }

    require 'json'
    #razor '-w', 'model', 'add', "'#{model.to_json}'"

    Puppet.debug "razor -w model add '#{model.to_pson}'"
    command = ['razor', '-w', 'model', 'add', "'#{model.to_pson}'"].join(" ")
    execute(command, :combine => true)
  end

  def destroy
    @property_hash[:ensure] = :absent
    razor '-w', 'model', 'remove', @property_hash[:uuid]
  end

  def exists?
    @property_hash[:ensure] == :present
  end
end
