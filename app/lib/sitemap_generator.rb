module SitemapGenerator

  require 'nokogiri'

  class Sitemap

    def initialize(base_url='/')
      @base_url = base_url
    end

    def generate
      xml_raw = '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"></urlset>'
      @doc = Nokogiri::XML(xml_raw)
      @urlset = @doc.root

      # add_url = Proc.new do |resource|
      #   url = Nokogiri::XML::Node.new('url', @doc)
      #   loc = Nokogiri::XML::Node.new('loc', @doc)
      #   lastmod = Nokogiri::XML::Node.new('lastmod', @doc)
      #   loc << resource_url(resource)
      #   lastmod << resource.updated_at.getutc.strftime('%Y-%m-%dT%H:%M:%S%:z')
      #   url << loc
      #   url << lastmod
      #   @urlset << url
      # end


      add_url = Proc.new do |loc_value, lastmod_value|
        url = Nokogiri::XML::Node.new('url', @doc)
        loc = Nokogiri::XML::Node.new('loc', @doc)
        lastmod = Nokogiri::XML::Node.new('lastmod', @doc)
        loc << loc_value.strip
        lastmod << lastmod_value
        url << loc
        url << lastmod
        @urlset << url
      end


      add_root_url = Proc.new do |resource|
        loc_value = resource_url(resource)
        lastmod_value = resource.updated_at.getutc.strftime('%Y-%m-%dT%H:%M:%S%:z')
        add_url.call(loc_value, lastmod_value)
      end


      add_content_url = Proc.new do |resource|
        loc_value = resource_url(resource)
        loc_value += '/contents'
        lastmod_value = resource.updated_at.getutc.strftime('%Y-%m-%dT%H:%M:%S%:z')
        add_url.call(loc_value, lastmod_value)
      end

      Resource.find_each do |r|
        add_root_url.call(r)
        add_content_url.call(r)
      end

      @doc.to_s
    end

    def resource_url(resource)
      if resource.eadid
        @base_url + resource.eadid
      else
        @base_url + 'resources/' + resource.id
      end
    end

  end

end
