require 'optparse'

# Argument parser for the command-line options
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

  def parse
    parser.parse!

    @options
  rescue => err
    puts "Argument Error: #{err.message}"
    exit 1
  end

  private

  def parser
    OptionParser.new do |opts|
      @opts = opts
      start_help_text
      add_options
    end
  end

  def start_help_text
    @opts.banner = "Usage:\n\tload_roadworks.rb <filename> [options]"
    @opts.separator ''
  end

  def add_options
    add_remote
    add_force
    add_noforce
    add_verbose
    add_progress
    add_help
  end

  def add_remote
    @opts.on('-r', '--remote',
            'Update the Heroku Database (Default: local).') do
      @options[:remote] = true
      @options[:progress] = 20 if @options[:progress] > 20
    end
  end

  def add_force
    @opts.on('-f', '--force',
            'Force the update, deleting all previous data (Default: Ask).') do
      @options[:force] = true
    end
  end

  def add_noforce
    @opts.on('-n', '--noforce',
            'Exit with a failure if there is previous data.') do
      @options[:noforce] = true
    end
  end

  def add_verbose
    @opts.on('-v', '--verbose', 'Turn on progress updates.') do
      @options[:verbose] = true
    end
  end

  def add_progress
    @opts.on('-p', '--progress VALUE',
            'Set the number of records between progress updates.') do |value|
      @options[:verbose] = true
      @options[:progress] = value.to_i
    end
  end

  def add_help
    @opts.on_tail('-h', '--help', 'Show this help') do
      puts @opts
      exit
    end
  end
end
