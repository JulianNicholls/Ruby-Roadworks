#!/usr/bin/env ruby -I.

require 'loader'

xml_file = ARGV[0] || "ha_roadworks_2015_06_15.xml"
loader = RoadworksLoaderFile.new xml_file
count = loader.count
if loader.count != 0      # Any records?
  print "There are #{count} records at present. Delete them? (Y/N) "
  answer = $stdin.gets.downcase
  exit unless answer[0] == 'y'
  loader.delete_all

  print "\nThere are now #{loader.count} records: "
  $stdin.gets
end

loader.process_xml
puts "\nDone."
