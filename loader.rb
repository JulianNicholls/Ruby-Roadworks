require 'nokogiri'
require 'sequel'
require 'forwardable'
require 'logger'

# Load the database from a file or string containing XML.
class RoadworksLoader
  # xpath for the contained roadworks.
  XPATH = '//ha_planned_works'.freeze

  # Table to massage the loaded XML fields to match the database fields.
  FIELDS_TABLE = {
    'reference_number'    => :delete,
    'local_authority'     => :delete,
    'expected_delay'      => 'delay',
    'traffic_management'  => 'management',
    'centre_easting'      => 'easting',
    'centre_northing'     => 'northing',
    'status'              => :delete,
    'published_date'      => :delete
  }.freeze

  # xml_data could be a file or HTML handle, or a string containing the entire
  # XML.

  def initialize(xml_data)
    initialize_data(Sequel.postgres('roadworks'), xml_data)
  end

  def count
    @roadworks.count
  end

  def delete_all
    @roadworks.delete
  end

  def process_xml(logger, options = {})
    works.each_with_index do |work, index|
      process_item work
      logger.print format("%4d...\r", index) if index % options[:progress] == 0
    end

    puts 'Committing...'
    @roadworks.import(@fields.keys, @records)
    logger.puts "\nRecords: #{count}"
  end

  private

  def initialize_data(db_connection, xml_data)
    @doc       = Nokogiri::XML xml_data
    @roadworks = db_connection[:roadworks]
  end

  def process_item(work)
    @fields = work.children.each_with_object({}) do |node, acc|
      name = node.name
      acc[name] = node.children.text unless name == 'text'
    end

    translate_field_names
    add_row_to_insert
  end

  def translate_field_names
    FIELDS_TABLE.each do |old_key, new_key|
      @fields[new_key] = @fields[old_key] unless new_key == :delete
      @fields.delete old_key
    end
  end

  def add_row_to_insert
    (@records ||= []) << @fields.values unless @fields['road'] == 'UETON'
  end

  def works
    @works ||= @doc.xpath XPATH
  end
end

# Load the remote database with the data
class RoadworksLoaderRemote < RoadworksLoader
  def initialize(xml_data)
    url = `heroku config:get DATABASE_URL`.chomp
    initialize_data(Sequel.connect(url), xml_data)
  end
end

# Load the data from a file
class RoadworksLoaderFile
  extend Forwardable

  def_delegators :@loader, :count, :delete_all, :process_xml

  def initialize(filename, remote)
    file = open filename
    @loader = if remote
                RoadworksLoaderRemote.new(file)
              else
                RoadworksLoader.new(file)
              end
  rescue => error
    puts "Cannot process #{filename}: #{error.message}"
    exit
  end
end
