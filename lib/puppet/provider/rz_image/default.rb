require 'fileutils'

Puppet::Type.type(:rz_image).provide(:default) do

  commands :razor => 'razor'
  commands :curl => 'curl'

  @image_type = {
    'MicroKernel Image'         => 'mk',
    'OS Install'                => 'os',
    'VMware Hypervisor Install' => 'esxi',
  }

  mk_resource_methods

  def self.instances
    razor_images = Array.new
    begin
      images = razor 'image', 'get'
      images = images.split("\n\n").collect{ |x| Hash[*(x.split(/\n|=>/) - ['Images']).collect{|y| y.strip!}] }
    rescue
      images = {}
    end

    images.each do |i|
      image = {
        :name => i['OS Name'] || i['ISO Filename'],
        :ensure => :present,
        :version => i['Version'] || i['OS Version'],
        :type => @image_type[i['Type']],
        :uuid => i['UUID'],
      }

      razor_images << new(image)
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

  def create
    @property_hash[:ensure] = :present

    begin
      if resource[:source] =~ /^http/
        tmpdir = Dir.mktmpdir(nil, '/var/tmp')
        source = File.join(tmpdir, resource[:name])
        curl '-L', resource[:source], '-a', '-o', source
      else
        source = resource[:source]
      end
      case resource[:type]
      when 'os'
        Puppet.debug "razor image add #{resource[:type]} #{resource[:source]} #{resource[:name]} #{resource[:version]}"
        razor 'image', 'add', resource[:type], source, resource[:name], resource[:version]
      else
        Puppet.debug "razor image add #{resource[:type]} #{resource[:source]}"
        razor 'image', 'add', resource[:type], source
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
