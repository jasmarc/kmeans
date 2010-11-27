$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
require "test/unit"
require "coordinate"

class TestCoordinate < Test::Unit::TestCase
  def test_basics
    c = Coordinate.new([1, 2])
    c2 = Coordinate.new([3, 4])
    puts c.distance_to(c2)
    puts c.add(c2)
  end
  
  def test_centroid
    p1 = Coordinate.new([-1, 1])
    p2 = Coordinate.new([2, 1])
    p3 = Coordinate.new([2, -1])
    p4 = Coordinate.new([-1, -1])
    puts Coordinate.centroid([p1, p2, p3, p4])
  end
  
  def test_print
    p = Coordinate.new([1, 2, 3])
    assert_equal("(1, 2, 3)", p.to_s)
  end
  
  def test_sphere
    100.times do |x|
      p = Coordinate.new([rand(10) + 1, rand(10) + 1])
      begin
          puts p.to_s
          p.sphere!
          assert_equal(1.0, p.norm.round, "assert failed")
      rescue => ex
        puts "error " + p.to_s + " " + ex
      end
    end
  end
  
  def test_sphere2
    p = Coordinate.new([0, 0])
    p.sphere!
    puts p.to_s
  end
end