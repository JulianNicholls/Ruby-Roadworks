#!/usr/bin/env ruby -I.

require 'open-uri'
require 'nokogiri'
require 'loader'

# Find the files, which are in anchors in list elements in a dropdown menu.
# There are three entries in each dropdown, only the correct one links to a
# FQ address.
class Finder
  def initialize(verbose = true)
    @verbose = verbose
    puts 'Searching...' if verbose

    noko  = Nokogiri::HTML open('http://data.gov.uk/dataset/highways_agency_planned_roadworks')
    files = noko.xpath('//div[@class="dropdown"]/ul/li/a[contains(@href,"http://")]')

    @latest   = files.map { |f| f['href'] }.sort.reverse.first
    @filename = File.split(@latest).last

    puts "\nLatest File: #{@filename}" if verbose
  end

  def save_file
    return unless confirm_write

    print 'Writing... ' if @verbose
    download

    output = open @filename, 'w'
    bytes  = output.write @xml

    puts "#{bytes} Bytes." if @verbose
  end

  def load_new_roadworks
    download

    loader = RoadworksLoader.new @xml
    loader.delete_all
    loader.process_xml @verbose
  end

  private

  def confirm_write
    return true unless File.exist? @filename

    print "\n#{@filename} exists, overwrite? (Y/N) "
    answer = $stdin.gets.downcase
    answer[0] == 'y'
  end

  def download
    xml_file = open @latest
    @xml ||= xml_file.read
  end
end

finder = Finder.new
finder.save_file
