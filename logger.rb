# Logger which outputs to $stdout

class OutLogger
  def self.print(*args)
    $stdout.print(*args)
  end

  def self.puts(*args)
    $stdout.puts(*args)
  end
end

# Logger which outputs nowhere, not even to /dev/null

class NullLogger
  def self.print(*)
    # Do nothing
  end

  def self.puts(*)
    # Do nothing
  end
end

# Return a logger class which either outputs to stdout or nowhere based on
# a verbosity flag.

class LoggerFactory
  def self.logger(verbose)
    verbose ? OutLogger : NullLogger
  end
end
