require "test/unit"
require "kmeans"
require "coordinate"

class TestKmeans < Test::Unit::TestCase
  def test_case_name
    x =   [[-0.4251,   -0.0549],
           [ 0.5894,   -1.1187],
           [-0.0628,   -0.6264],
           [-2.0220,    0.2495],
           [-0.9821,   -0.9930],
           [ 0.6125,    0.9750],
           [ 9.3593,    9.4067],
           [11.8089,   10.4013],
           [ 8.9201,   10.9421],
           [10.1992,   10.3005],
           [ 8.4790,    9.6269],
           [ 9.2764,   10.8155],
           [20.7989,   19.3428],
           [20.1202,   19.3961],
           [20.5712,   20.1769],
           [20.4128,   19.6925],
           [19.0130,   19.8682],
           [20.7596,   20.5954]]
    x.sort! { rand }
    elements = []
    x.each_index do |idx|
      element = Coordinate.new(x[idx])
      element.data = idx
      elements << element
    end
    elements.each do |element|
      puts element.data.to_s + "\t" + element.to_s
    end
    kmeans = KMeans.new(elements, 3)
    puts kmeans.to_s
    clusters = kmeans.compute
    puts kmeans.to_s
  end
end