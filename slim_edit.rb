require 'date'

# File editor for a slim file
class SlimEditor
  def initialize(filename)
    @lines = File.new(@filename = filename).readlines
  end

  def replace_date
    span_idx = @lines.find_index { |line| line =~ /span/ }

    @lines[span_idx + 1].sub!(/\d{2} \w+ \d{4}/, @date.strftime('%d %B %Y'))

    File.open(@filename, 'w') { |file| write_lines file }
  end

  def date_from_filename(name)
    datepart = name.sub(/h._roadworks_(\d{4})_(\d{2})_(\d{2})\S+/, '\1-\2-\3')

    @date = Date.parse datepart

    self
  end

  def date=(date)
    @date = date.respond_to?(:strftime) ? date : Date.parse(date)
  end

  private

  def write_lines(file)
    @lines.each { |line| file.write line }
  end
end
