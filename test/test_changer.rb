require 'minitest/autorun'
require 'minitest/pride'

require './changer'

# Test class for Calculate555 resistor value calculations from
# period/frequency and duty cycle.
class TextChangerTest < Minitest::Test
  def test_junction_singles
    assert_equal 'up the Junction', TextChanger.multi_gsub('up the jn', 'A1')
    assert_equal 'up the Junction', TextChanger.multi_gsub('up the jct', 'A1')
    assert_equal 'up the Junction', TextChanger.multi_gsub('up the jct jct', 'A1')
    assert_equal 'up the Junction 5', TextChanger.multi_gsub('up the j5', 'A1')
    assert_equal 'up the Junction 21', TextChanger.multi_gsub('up the jct21', 'A1')
  end

  def test_junction_singles_upper
    assert_equal 'up the Junction', TextChanger.multi_gsub('up the JN', 'A1')
    assert_equal 'up the Junction', TextChanger.multi_gsub('up the JCT', 'A1')
    assert_equal 'up the Junction', TextChanger.multi_gsub('up the JCT JCT', 'A1')
    assert_equal 'up the Junction 5', TextChanger.multi_gsub('up the J5', 'A1')
    assert_equal 'up the Junction 21', TextChanger.multi_gsub('up the JCT21', 'A1')
  end

  def test_junction_singles_mixed
    assert_equal 'up the Junction', TextChanger.multi_gsub('up the Jn', 'A1')
    assert_equal 'up the Junction', TextChanger.multi_gsub('up the Jct', 'A1')
    assert_equal 'up the Junction', TextChanger.multi_gsub('up the Jct Jct', 'A1')
    assert_equal 'up the Junction 21', TextChanger.multi_gsub('up the Jct21', 'A1')
  end

  def test_bound_directions
    assert_equal 'Go Westbound', TextChanger.multi_gsub('Go WB', 'A1')
    assert_equal 'Heading Northbound',
                 TextChanger.multi_gsub('Heading NB', 'A1')
    assert_equal 'It\'s all gone Southbound',
                 TextChanger.multi_gsub('It\'s all gone SB', 'A1')
    assert_equal 'Eastbound and down',
                 TextChanger.multi_gsub('EB and down', 'A1')
  end

  def test_unbound_directions
    assert_equal 'Go West', TextChanger.multi_gsub('Go west', 'A1')
    assert_equal 'Heading North', TextChanger.multi_gsub('Heading north', 'A1')
    assert_equal 'It\'s all gone South',
                 TextChanger.multi_gsub('It\'s all gone south', 'A1')
    assert_equal 'East bound and down',
                 TextChanger.multi_gsub('east bound and down', 'A1')
  end

  def test_hardshoulder
    assert_equal 'Stuck on the hard shoulder',
                 TextChanger.multi_gsub('Stuck on the hardshoulder', 'A1')
  end

  def test_carriageway
    assert_equal 'Stuck in the carriageway',
                 TextChanger.multi_gsub('Stuck in the c/way', 'A1')
  end

  def test_and
    assert_equal 'This and that',
                 TextChanger.multi_gsub('This & that', 'A1')
  end

  def road_removal
    assert_equal ' Update: blocked carriageway Northbound',
                 TextChanger.multi_gsub('A1 Update: blocked c/way NB', 'A1')
  end
end
