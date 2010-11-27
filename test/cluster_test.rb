$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
require "test/unit"
require "cluster"
require "coordinate"

class TestCluster < Test::Unit::TestCase
  def test_basics
    element = Coordinate.new([0, 0])
    element.data = "jason"
    cluster = Cluster.new(element)
    assert(cluster.elements.size == 1, "cluster has one element")
    assert_equal(0, cluster.distance_to(element))
    element2 = Coordinate.new([3, 4])
    element2.data = "some other data"
    cluster.add(element2)
    cluster.recalculate_centroid
    assert_equal(2.5, cluster.distance_to(element))
    cluster.elements.each do |element|
      puts element.to_s + "\t" + element.data
    end
  end
    
  def test_remove
    element = Coordinate.new([0, 0])
    cluster = Cluster.new(element)
    assert_equal(1, cluster.elements.size)
    cluster.remove(cluster.elements.first)
    assert_equal(0, cluster.elements.size)
    cluster.add(element)
    assert_equal(1, cluster.elements.size)
  end
  
  def test_centroid
    coord1 = Coordinate.new([1, 0])
    coord2 = Coordinate.new([1, 1])
    coord3 = Coordinate.new([1, 3])
    coords1 = [coord1, coord2]
    coords2 = [coord1, coord3]
    assert_not_equal(coords1, coords2)
    coords2 = [coord1, coord2]
    assert_equal(coords1, coords2)
    assert_not_equal(nil, coords2)
  end
end