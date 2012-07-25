require 'fileutils'
require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.dirname.expand_path + 'puppet_x/puppet_labs/razor'

Puppet::Type.type(:rz_image).provide(:default) do

  commands :razor => 'razor'

  def self.query_razor
    PuppetX::PuppetLabs::Razor.new(method(:razor))
  end

  def query_razor
    self.class.query_razor
  end

  mk_resource_methods

  def self.instances
    razor_images = Array.new

    images = query_razor.get_images

    images.each do |i|
      i[:ensure] = :present
      # fallback to use the image iso name for mk.
      i[:name]   = i[:name] || i[:isoname]
      razor_images << new(i)
    end
    razor_images
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

  def download(source, target)
    curl '-L', source, '-a', '-o', target
  end

  def create
    @property_hash[:ensure] = :present

    begin
      if resource[:source] =~ /^http/
        tmpdir = Dir.mktmpdir(nil, '/var/tmp')
        iso_file = File.join(tmpdir, resource[:name])
        download(resource[:source], iso_file)
      else
        iso_file = resource[:source]
      end
      case resource[:type]
      when :os
        Puppet.debug "razor image add #{resource[:type]} #{resource[:source]} #{resource[:name]} #{resource[:version]}"
        razor 'image', 'add', resource[:type], iso_file, resource[:name], resource[:version]
      else
        Puppet.debug "razor image add #{resource[:type]} #{resource[:source]}"
        razor 'image', 'add', resource[:type], iso_file
      end
    ensure
      FileUtils.remove_entry_secure(tmpdir) if tmpdir
    end
  end

  def destroy
    @property_hash[:ensure] = :absent
    razor 'image', 'remove', @property_hash[:uuid]
  end

  def exists?
    @property_hash[:ensure] == :present
  end
end
