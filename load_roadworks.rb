#!/usr/bin/env ruby -I.

require 'arg_parser.rb'
require 'logger'
require 'loader'
require 'confirmation'

# Parse the command line

options = CommandLineParser.new.parse

# After running the command line parser there should be a single option
# left; The filename to load.

if ARGV.count != 1
  puts "\nArgument Error: XML Filename must be specified"
  exit 1
end

loader = RoadworksLoaderFile.new(ARGV[0], options[:remote])
logger = LoggerFactory.logger options[:verbose]

record_count = loader.count

if record_count > 0
  display_prompt = options[:verbose] || !options[:force]
  puts "There are #{record_count} records at present." if display_prompt

  # Bail out if noforce is set
  exit(1) if options[:noforce]

  # Otherwise ask the user to confirm deletion
  unless options[:force]
    exit(1) unless Confirm.ask 'Delete them'
  end

  loader.delete_all
end

loader.process_xml logger, options

logger.puts "\nDone."
