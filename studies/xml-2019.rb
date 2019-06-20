require 'nokogiri'

xml_file = open(ARGV[0] || 'he_roadworks_2019_04_15.xml')
top = Nokogiri::XML xml_file

top.remove_namespaces!

works = top.xpath '//HE_PLANNED_WORKS'

puts "#{works.count} planned works"

item = works[0]

item.attributes.keys.each do |key|
  puts "  #{item.attributes[key].name}: #{item.attributes[key].value}"
end
