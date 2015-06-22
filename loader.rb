require 'nokogiri'
require 'sequel'

class RoadworksLoader
  # Table to massage the loaded xml fields to match the database fields.

  FIELDS_TABLE = {
    'reference_number'    => nil,
    'local_authority'     => nil,
    'expected_delay'      => 'delay',
    'traffic_management'  => 'management',
    'centre_easting'      => 'easting',
    'centre_northing'     => 'northing',
    'status'              => nil,
    'published_date'      => nil
  }

  # xml_data could be a file or HTML handle, or a string containing the entire
  # XML.

  def initialize(xml_data)
    @doc       = Nokogiri::XML(xml_data)
    db         = Sequel.postgres('roadworks')
    @roadworks = db[:roadworks]
  end

  def count
    @roadworks.count
  end

  def delete_all
    @roadworks.delete
  end

  def process_xml(verbose = true)
    works = @doc.xpath('//ha_planned_works')

    count = 0

    works.each do |work|
      process_item work
      count += 1
      print "#{count}... " if verbose && count % 100 == 0
    end
  end

  private

  def process_item(work)
    @fields = work.children.reduce({}) do |acc, node|
      acc[node.name] = node.children.text if node.name != 'text'
      acc
    end

    translate_field_names
    add_row
  end

  def translate_field_names
    FIELDS_TABLE.each do |old_key, new_key|
      @fields[new_key] = @fields[old_key] unless new_key.nil?
      @fields.delete old_key
    end
  end

  def add_row
    @roadworks.insert @fields
  end
end

class RoadworksLoaderFile < RoadworksLoader
  def initialize(filename)
    file = open filename

    super(file)
  rescue => e
    puts "Cannot open #{filename}: #{e.message}"
    exit
  end
end
