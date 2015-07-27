#!/usr/bin/env ruby -I.

require 'open-uri'
require 'nokogiri'
require 'loader'

# Find the files, which are in anchors in list elements in a dropdown menu.
# There are three entries in each dropdown, only the correct one links to a
# FQ address.
class Finder
  DATA_PAGE  = 'http://data.gov.uk/dataset/highways_agency_planned_roadworks'
  DATA_XPATH = '//div[@class="dropdown"]/ul/li/a[contains(@href,"http://")]'

  def initialize(verbose)
    @verbose = verbose
    puts 'Searching...' if verbose

    noko  = Nokogiri::HTML open(DATA_PAGE)
    @files = noko.xpath DATA_XPATH

    @latest   = sorted_files
    @filename = File.split(@latest).last

    puts "\nLatest File: #{@filename}" if verbose
  end

  def save_file
    return unless confirm_write

    print 'Writing... ' if @verbose

    output = open @filename, 'w'
    bytes  = output.write xml

    puts "#{bytes} Bytes." if @verbose
  end

  def load_new_roadworks
    loader = RoadworksLoader.new xml
    loader.delete_all
    loader.process_xml @verbose
  end

  private

  def sorted_files
    @files.map { |file| file['href'] }.sort_by do |href|
      href.gsub(/ha_roadworks/, 'ha-roadworks')
    end.reverse.first
  end

  def confirm_write
    return true unless File.exist? @filename

    print "\n#{@filename} exists, overwrite? (Y/N) "
    answer = $stdin.gets.downcase
    answer[0] == 'y'
  end

  def xml
    xml_file = open @latest
    @xml ||= xml_file.read
  end
end

finder = Finder.new(:verbose)
finder.save_file
