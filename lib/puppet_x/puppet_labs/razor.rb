require 'net/http'
require 'pathname'
require Pathname.new(__FILE__).dirname.expand_path

module PuppetX::PuppetLabs
  class Razor

    def initialize(razor=nil)
      @razor = razor
    end

    def get_images
      begin
        # This command does not support '-w' flag yet, so processing the output.
        images = razor 'image', 'get'
        Puppet.debug(images.inspect)
        @images = images.split("\n\n").collect{ |x| Hash[*(x.split(/\n|=>/) - ['Images']).collect{|y| y.strip!}] }
      rescue
        Puppet.debug "Failed to gather results from command 'razor image get'."
        @images = {}
      end
      @images = image_map(@images)
    end

    def get_models
      output = razor '-w', 'model', 'get', 'default'
      uuids = parse(output).collect{ |x| x['@uuid'] if x.include? '@uuid'}.compact
      models = uuids.collect do |id|
        output = razor '-w', 'model', 'get', id
        res = strip_at(parse(output).first)
        metadata = Hash.new
        res[:req_metadata_hash].keys.each do |k|
          metadata[k] = res[k] if res.include? k
        end
        model = {
          :name        => res[:label],
          :description => res[:description],
          :image       => get_image_name(res[:image_uuid]),
          :metadata    => metadata,
          :template    => res[:name],
          :uuid        => res[:uuid],
        }
      end
    end

    def get_policies
      output = razor '-w', 'policy', 'get', 'default'
      uuids = parse(output).collect{ |x| x['@uuid'] if x.include? '@uuid'}.compact
      policies = uuids.collect do |id|
        output = razor '-w', 'policy', 'get', id
        res = strip_at(parse(output).first)
        policy = {
          :name        => res[:label],
          :description => res[:description],
          :uuid        => res[:uuid],
          :model       => res[:model][:label],
          :tags        => res[:tags],
          :enabled     => res[:enabled],
          :maximum     => res[:maximum_count],
          :broker      => res[:broker] || 'none',
        }
      end
    end

    def get_tags
      output = razor '-w', 'tag', 'get', 'default'
      uuids = parse(output).collect{ |x| x['@uuid'] if x.include? '@uuid'}.compact
      tags = uuids.collect do |id|
        output = razor '-w', 'tag', 'get', id
        res = strip_at(parse(output).first)

        matchers = res[:tag_matchers].collect{ |m| strip_at(m) }
        matchers = matchers.collect do |m|
          m.delete_if{ |k, v| [:classname, :id, :is_template, :uri, :version].include? k }
          m
        end

        tag = {
          :name        => res[:name],
          :uuid        => res[:uuid],
          :tag_matcher => matchers,
          :tag_label   => res[:tag],
        }
      end
    end

    def add_tag(value)
      output = razor '-w', 'tag', 'add', value
      uuid = parse(output).collect{ |x| x['@uuid'] if x.include? '@uuid'}.first
    end

    def get_model_uuid(name)
      begin
        model = models.find{|x| x[:name] == name}
        model[:uuid]
      rescue Exception => e
        Puppet.debug e.message
        raise Puppet::Error, "Failed to find model uuid for label #{name}."
      end
    end

    def get_image_name(uuid)
      begin
        image = images.find{|x| x[:uuid] == uuid}
        image[:name]
      rescue Exception => e
        Puppet.debug e.message
        raise Puppet::Error, "Failed to find image name for uuid #{uuid}."
      end
    end

    def get_image_uuid(name)
      begin
        image = images.find{|x| x[:name] == name}
        image[:uuid]
      rescue Exception => e
        Puppet.debug e.message
        raise Puppet::Error, "Failed to find image uuid for name #{name}."
      end
    end

    private

    define_method(:razor) do |*args|
      @razor.call args
    end

    def images
      @images ||= get_images
    end

    def models
      @models ||= get_models
    end

    def parse(response)
      result = PSON.parse(response)
      if result.include? 'response'
        result['response']
      else
        raise Puppet::Error, "Failed to parse output from razor: \n#{response.inspect}"
      end
    end

    def strip_at(val)
      result = Hash.new
      val.each do |k, v|
        if v.is_a? Hash
          result[k.delete('@').to_sym] = strip_at(v)
        else
          result[k.delete('@').to_sym] = v
        end
      end
      result
    end

    def image_map(images)
      image_keymap = {
        'ISO Filename' => :isoname,
        'OS Name'      => :name,
        'Version'      => :version,
        'OS Version'   => :version,
        'Type'         => :type,
        'UUID'         => :uuid,
        'Path'         => :path,
        'Status'       => :status,
      }

      image_type = {
        'MicroKernel Image'         => 'mk',
        'OS Install'                => 'os',
        'VMware Hypervisor Install' => 'esxi',
      }

      result = images.collect do |i|
        image = i.map do |k, v|
          if k == 'Type'
            [image_keymap[k], image_type[v]]
          elsif image_keymap.include? k
            [image_keymap[k], v]
          end
        end
        Hash[image.compact]
      end
      result
    end
  end
end
