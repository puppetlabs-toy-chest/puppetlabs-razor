require 'fileutils'
require 'uri'
require 'pathname'
require 'digest/md5'
require Pathname.new(__FILE__).dirname.dirname.dirname.dirname.expand_path + 'puppet_x/puppet_labs/razor'

Puppet::Type.type(:rz_image).provide(:default) do

  commands :razor => 'razor'
  commands :curl  => 'curl'

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
    if File.exist?(target) && md5_match?(target, resource[:md5sum])
      Puppet.notice("Using cached rz_image from #{target} ...")
    else
      Puppet.notice("Downloading rz_image from #{source} to #{target} ...")
      FileUtils.mkdir_p(File.dirname(target))
      curl '-f', '-L', source, '-a', '-o', target
    end
  end

  def create
    @property_hash[:ensure] = :present

    begin
      uri = URI.parse(resource[:source])
      if uri.scheme =~ /^http/
        target = File.join(resource[:cache], File.basename(uri.path))
        download(resource[:source], target)
      else
        target = resource[:source]
        download(resource[:url], target)
      end

      options = [
        '-t', resource[:type],
        '-p', resource[:source],
        ]
      if resource[:type] === :os
        options += [
          '-n', resource[:name],
          '-v', resource[:version],
          ]
      end

      Puppet.debug "razor image add #{options.join(' ')}"
      razor 'image', 'add', *options
    end
  end

  def destroy
    @property_hash[:ensure] = :absent
    razor 'image', 'remove', @property_hash[:uuid]
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  # Match a given md5 with the file in source.
  #
  # Returns true if the md5 is not set.
  # Returns true if the md5 given matches with the file's md5.
  # Returns false if there is a mismatch between digests.
  def md5_match?(file, md5)
    return true if md5.nil?

    digest = Digest::MD5.file(source).hexdigest
    return true if digest == md5

    Puppet.info("Image md5 mismatch: expected #{md5} but it was #{digest}.")
    false
  end
end
