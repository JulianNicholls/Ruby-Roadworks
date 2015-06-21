require 'open-uri'
require 'nokogiri'

# Find the files, which are in anchors in list elements in a dropdown menu.
# there are three entries, only one links to a FQ address.

puts 'Searching...'
noko  = Nokogiri::HTML open('http://data.gov.uk/dataset/highways_agency_planned_roadworks')
files = noko.xpath('//div[@class="dropdown"]/ul/li/a[contains(@href,"http://")]')

latest = files.map { |f| f['href'] }.sort.reverse.first
filename = File.split(latest)[1]

puts "\nLatest File: #{filename}"

if File.exist? filename
  print "\n#{filename} exists, overwrite? (Y/N) "
  answer = $stdin.gets.downcase
  exit unless answer[0] == 'y'
end

xml = open latest

print 'Writing... '
output = open filename, 'w'
bytes = output.write xml.read
puts "#{bytes} Bytes."
