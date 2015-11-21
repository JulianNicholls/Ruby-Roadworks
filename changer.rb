# Change the text of the location and description
class TextChanger
  CHANGES = {
    /jn/i           => 'Junction',
    /jct(\d)/i      => 'Junction \1',
    /j(\d)/i        => 'Junction \1',
    /jct jct/i      => 'Junction',
    /jct/i          => 'Junction',
    /SB/            => 'Southbound',
    /NB/            => 'Northbound',
    /WB/            => 'Westbound',
    /EB/            => 'Eastbound',
    /\bsouth/i      => 'South',
    /\bnorth/i      => 'North',
    /\bwest/i       => 'West',
    /\beast/i       => 'East',
    /hardshoulder/i => 'hard shoulder',
    %r{c/way}       => 'carriageway',
    /&/             => 'and'
  }

  def self.multi_gsub(str, road)
    CHANGES.each { |search, replace| str.gsub!(search, replace) }

    str.gsub(/#{road}/i, '')
  end
end

