#!/usr/bin/env ruby -I.

require 'optparse'
require 'loader'


class CommandLineParser
  def initialize
    @options = {
      remote:     false,
      force:      false,
      noforce:    false,
      verbose:    false,
      progress:   100
    }

    @parser = OptionParser.new do |opts|
      opts.banner = "Usage:\n\tload_roadworks.rb <filename> [options]"
      opts.separator ""

      opts.on('-r', '--remote',
              'Update the Heroku Database (Default: local).') do
        @options[:remote] = true
        @options[:progress] = 50
      end

      opts.on('-f', '--force',
              'Force the update, deleting all previous data (Default: Ask).') do
        @options[:force] = true
      end

      opts.on('-n', '--noforce',
              'Skip the update and return failure if there is previous data.') do
        @options[:noforce] = true
      end

      opts.on('-v', '--verbose', 'Turn on progress updates.') do
        @options[:verbose] = true
      end

      opts.on_tail('-h', '--help', 'Show this help') do
        puts opts
        exit
      end
    end
  end

  def parse
    @parser.parse!

    @options
  rescue => err
    puts "Argument Error: #{err.message}"
    exit 1
  end
end

#----------------------------------------------------------------------------
# Main
#----------------------------------------------------------------------------

options = CommandLineParser.new.parse

if ARGV.count != 1
  puts "\nArgument Error: XML Filename must be specified"
  exit 1
end

loader = RoadworksLoaderFile.new ARGV[0], options[:remote]
logger = options[:verbose] ? OutLogger : NullLogger

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

loader.process_xml logger, options

logger.puts "\nDone."
