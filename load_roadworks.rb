#!/usr/bin/env ruby -I.

require 'optparse'
require 'loader'

# Arguengt parser for the command-line options
class CommandLineParser
  def initialize
    @options = {
      remote:     false,
      force:      false,
      noforce:    false,
      verbose:    false,
      progress:   100
    }
  end

  def parser
    OptionParser.new do |opts|
      opts.banner = "Usage:\n\tload_roadworks.rb <filename> [options]"
      opts.separator ''

      add_remote opts
      add_force opts
      add_noforce opts
      add_verbose opts
      add_help opts
    end
  end

  def parse
    parser.parse!

    @options
  rescue => err
    puts "Argument Error: #{err.message}"
    exit 1
  end

  private

  def add_remote(opts)
    opts.on('-r', '--remote',
            'Update the Heroku Database (Default: local).') do
      @options[:remote] = true
      @options[:progress] = 50
    end
  end

  def add_force(opts)
    opts.on('-f', '--force',
            'Force the update, deleting all previous data (Default: Ask).') do
      @options[:force] = true
    end
  end

  def add_noforce(opts)
    opts.on('-n', '--noforce',
            'Exit with a failure if there is previous data.') do
      @options[:noforce] = true
    end
  end

  def add_verbose(opts)
    opts.on('-v', '--verbose', 'Turn on progress updates.') do
      @options[:verbose] = true
    end
  end

  def add_help(opts)
    opts.on_tail('-h', '--help', 'Show this help') do
      puts opts
      exit
    end
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

  # Bail out if noforce is set
  exit(1) if options[:noforce]

  # Otherwise ask the user to confirm, deletion of the previous records
  unless options[:force]
    print 'Delete them? (Y/N) '
    answer = $stdin.gets.downcase
    exit(1) unless answer[0] == 'y'
  end

  loader.delete_all
end

loader.process_xml logger, options

logger.puts "\nDone."
