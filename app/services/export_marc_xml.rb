class ExportMarcXml

  def self.call(options={})
    object = new(options)
    object.call
  end

  def initialize(options={})
    @options = options
    @days = @options[:days].to_i
    @days = @days > 0 ? @days : 7
    # @since = (Date.today - @days).to_datetime.strftime('%Y-%m-%dT%H:%M:%SZ')
    @since = (Date.today - @days)
    
    @a = ArchivesSpaceApiUtility::ArchivesSpaceSession.new
  end

  def call
    execute
  end


  private


  def execute
    create_xml_doc
    get_record_ids
    @ids.each do |id|
      puts "Adding MARC XML for Resource #{id}..."
      marc_doc = marc_xml_doc(id)
      if marc_doc
        record = marc_doc.root.first_element_child
        @doc.root.add_child(record)
      end
    end
    export_file
  end

  def create_xml_doc
    puts "Creating XML document..."
    xml = '<?xml version="1.0" encoding="UTF-8"?>
      <marc:collection xmlns="http://www.loc.gov/MARC21/slim" xmlns:marc="http://www.loc.gov/MARC21/slim"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd
      http://www.loc.gov/MARC21/slim"></marc:collection>'
    @doc = Nokogiri::XML(xml)
  end

  def get_record_ids
    puts "Finding resources updated in the last #{@days} days..."
    # get_updated_records()
    Resource.where("created_at >= '#{@since}'").map { |r| r.id }
  end

  def marc_xml_doc(id)
    uri = "/repositories/2/resources/marc21/#{id}.xml"
    response = @a.get(uri)
    if response.code == '200'
      Nokogiri::XML(response.body)
    else
      puts; puts "***"
      puts "Error retrieving MARC XML for Resource #{id}: #{response.body}"
      puts "***"; puts
      nil
    end
  end

  def export_file
    filename = "marc_xml_#{(Date.today - @days).to_s}_#{Date.today.to_s}.xml"
    tmp_path = Rails.root.to_s + '/tmp'
    path = "#{tmp_path}/#{filename}"
    file = File.new(path,'w')
    file << @doc.to_s
    file.close
    puts "XML file saved to #{path}"
    { report_path: path }
  end

end
