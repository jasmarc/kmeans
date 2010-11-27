require "rubygems"
require "test/unit"
require "coordinate"
require "kmeans"
require "ruby-prof"

class TestReadFile < Test::Unit::TestCase
  def test_case_name
    f = File.open("wiveryn.txt", "r") 
    coords = []
    count = 0
    f.each_line do |line|
      coord = Coordinate.new(line.split("\t").map{ |x| x.to_f })
      coord.sphere!
      coords << coord
      count += 1
    end
    RubyProf.start
    kmeans = KMeans.new(coords, 3)
    kmeans.compute
    result = RubyProf.stop

    # Print a flat profile to text
    printer = RubyProf::FlatPrinter.new(result)
    printer.print(STDOUT, 0)
  end
  
  def test_snippet
    File.open("../test 30/file02.txt", "r") do |f|
      f.seek(12)
      puts f.read(50)
    end
  end
end