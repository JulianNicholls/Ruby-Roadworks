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
      opts.banner = "Usage:\n\tload_roadworks.rb <filename> [options]"
      opts.separator ''

      add_remote opts
      add_force opts
      add_noforce opts
      add_verbose opts
      add_help opts
    end
  end

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
