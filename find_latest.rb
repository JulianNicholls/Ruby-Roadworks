#!/usr/bin/env ruby -I.

require 'open-uri'
require 'nokogiri'
require 'loader'
require 'logger'
require 'slim_edit'
require 'confirmation'

# Find the files, which are in anchors in list elements in a dropdown menu.
# There are three entries in each dropdown, only the correct one links to a
# FQ address.
class Finder
  DATA_PAGE  = 'https://data.gov.uk/dataset/highways_agency_planned_roadworks'
  DATA_XPATH = '//div[@class="dropdown"]/ul/li/a[contains(@href,"http://")]'

  def initialize(logger)
    @logger = logger
    logger.puts 'Searching...'

    noko = Nokogiri::HTML open(DATA_PAGE)
    @files = noko.xpath DATA_XPATH

    logger.puts "\nLatest File: #{filename}"
  end

  def save_file
    return false unless confirm_write

    @logger.print 'Writing... '

    bytes = File.write filename, xml

    @logger.puts "#{bytes} Bytes.\nUpdating index.slim file"

    SlimEditor.new('views/index.slim')
      .date_from_filename(filename)
      .replace_date
  end

  def load_local_roadworks
    loader = RoadworksLoader.new xml
    loader.delete_all
    loader.process_xml @logger, progress: 100
  end

  private

  # Recently there have been a couple of mistakes with naming on the site:
  #   First was a couple of files named ha-roadworks... instead of ha_roadworks
  #   From early August '15 the name is sometimes he_roadworks...
  def sorted_files
    @files.map { |file| file['href'] }.sort_by do |href|
      href.gsub(/h[ae][_-]roadworks/, 'ha-roadworks')
    end.reverse
  end

  def confirm_write
    return true unless File.exist? filename

    Confirm.ask "\n#{filename} exists, overwrite"
  end

  def xml
    xml_file = open latest
    @xml ||= xml_file.read
  end

  def latest
    @latest ||= sorted_files.first
  end

  def filename
    @filename ||= File.split(latest).last
  end
end

finder = Finder.new(OutLogger)

if finder.save_file && Confirm.ask('Update local roadworks database')
  finder.load_local_roadworks
end
