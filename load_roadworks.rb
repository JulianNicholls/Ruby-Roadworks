#!/usr/bin/env ruby -I.

require 'optparse'
require 'loader'

options = {
  remote:     false,
  force:      false,
  noforce:    false,
  verbose:    false,
  progress:   100
}

parser = OptionParser.new do |opts|
  opts.banner = 'Usage:  load_roadworks.rb <filename> [options]'

  opts.on('-r', '--remote',
          'Update the Heroku Database (Default: local).') do
    options[:remote] = true
    options[:progress] = 50
  end

  opts.on('-f', '--force',
          'Force the update, deleting all previous data (Default: Ask).') do
    options[:force] = true
  end

  opts.on('-n', '--noforce',
          'Skip the update and return failure if there is previous data.') do
    options[:noforce] = true
  end

  opts.on('-v', '--verbose',
          'Turn on progress updates.') do
    options[:verbose] = true
  end

  opts.on_tail('-h', '--help', 'Show this help') do
    puts opts
    exit
  end
end

begin
  parser.parse!
rescue => e
  puts 'Argument Error: ' + e.message
  exit 1
end

if ARGV.count != 1
  puts "\nArgument Error: XML Filename must be specified"
  exit 1
end

loader = RoadworksLoaderFile.new ARGV[0], options[:remote]

record_count = loader.count

if record_count > 0
  display_prompt = options[:verbose] || !options[:force]
  puts "There are #{record_count} records at present." if display_prompt
  exit(1) if options[:noforce]  # Bail out if noforce is set

  unless options[:force]
    print 'Delete them? (Y/N) '
    answer = $stdin.gets.downcase
    exit(1) unless answer[0] == 'y'
  end

  loader.delete_all
end

loader.process_xml options

puts "\nDone." if options[:verbose]
