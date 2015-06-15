#!/usr/bin/env ruby -I.

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

  def initialize(filename)
    @doc       = Nokogiri::XML(File.open(filename))
    db         = Sequel.postgres('roadworks')
    @roadworks = db[:roadworks]
  rescue => e
    puts "Cannot open #{filename}: #{e.message}"
    exit
  end

  def process_file(verbose = true)
    works = @doc.xpath('//ha_planned_works')

    count = 0

    works.each do |work|
      process_item work
      count += 1
      print "#{count}... " if count % 100 == 0 && verbose
    end
  end

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

xml_file = ARGV[0] || "ha_roadworks_2015_06_15.xml"
loader = RoadworksLoader.new xml_file
loader.process_file
puts "\nDone."
