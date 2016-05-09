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
  PAGE  = 'https://data.gov.uk/dataset/highways_agency_planned_roadworks'.freeze
  XPATH = '//div[@class="inner-cell"]/span/a[contains(@href,"http://")]'.freeze

  def initialize(logger)
    @logger = logger
    logger.puts 'Searching...'

    noko = Nokogiri::HTML open(PAGE)
    @files = noko.xpath XPATH

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

    set_heroku_variable
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
    if option.casecmp('-n') == 0
      puts 'Already downloaded, exiting.'
      return false
    else
      Confirm.ask_yes_no "\n#{filename} exists, overwrite"
    end
  end

  def xml
    xml_file = open latest
    @xml ||= xml_file.read
  rescue StandardError => err
    abort "\nCannot read from #{latest}\nError: #{err}"
  end

  def latest
    @latest ||= sorted_files.first
  end

  def filename
    @filename ||= File.split(latest).last
  rescue StandardError
    abort "No file found in page."
  end
end

finder = Finder.new(OutLogger)

if finder.save_file
  finder.load_local_roadworks  if Confirm.ask_yes_no('Update local database')
  finder.load_remote_roadworks if Confirm.ask_yes_no('Update remote database')
end
