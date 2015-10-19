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
      start_help_text opts
      add_options opts
    end
  end

  def start_help_text(opts)
    opts.banner = "Usage:\n\tload_roadworks.rb <filename> [options]"
    opts.separator ''
  end

  def add_options(opts)
    add_remote opts
    add_force opts
    add_noforce opts
    add_verbose opts
    add_progress opts
    add_help opts
  end

  def add_remote(opts)
    opts.on('-r', '--remote',
            'Update the Heroku Database (Default: local).') do
      @options[:remote] = true
      @options[:progress] = 20 if @options[:progress] > 20
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

  def add_progress(opts)
    opts.on('-p', '--progress VALUE',
            'Set the number of records between progress updates.') do |value|
      @options[:verbose] = true
      @options[:progress] = value.to_i
    end
  end

  def add_help(opts)
    opts.on_tail('-h', '--help', 'Show this help') do
      puts opts
      exit
    end
  end
end
