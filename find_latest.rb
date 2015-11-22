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

    @logger.puts "#{bytes} Bytes."
    true
  end

  def load_local_roadworks
    loader = RoadworksLoader.new xml
    loader.delete_all
    loader.process_xml @logger, progress: 100
  end

  def load_remote_roadworks
    loader = RoadworksLoaderRemote.new xml
    loader.delete_all
    loader.process_xml @logger, progress: 20
  end

  def set_heroku_variable
    puts "\nUpdating Heroku environment"

    datepart  = filename.sub(/works_(\d{4})_(\d{2})_(\d{2})\./, '\1-\2-\3')
    date      = Date.parse datepart
    date_str  = date.strftime('%d %B %Y')

    `heroku config:set DATA_FILE_DATE='#{date_str}'`
  end

  private

  # Recently there have been a couple of changes / mistakes with naming:
  #   First was a couple of files named ha-roadworks... instead of ha_roadworks
  #   From early August '15 the name is sometimes he_roadworks...
  def sorted_files
    @files.map { |file| file['href'] }.sort_by do |href|
      href.gsub(/h[ae][_-]roadworks/, 'ha-roadworks')
    end.reverse
  end

  def confirm_write
    return true unless File.exist? filename

    option = ARGV[0] || ''
    if option.downcase == '-n'
      puts 'Already downloaded, exiting.'
      return false
    else
      Confirm.ask "\n#{filename} exists, overwrite"
    end
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

if finder.save_file
  finder.load_local_roadworks  if Confirm.ask('Update local database')
  finder.load_remote_roadworks if Confirm.ask('Update remote database')

  finder.set_heroku_variable
end
