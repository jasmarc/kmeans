class Coordinate < Array
  attr_accessor :data, :cluster
  
  def Coordinate.centroid(coordinates)
    centroid = Coordinate.new(coordinates.first.size) { 0 }
    coordinates.each do |coordinate|
      centroid.add(coordinate)
    end
    centroid.map! { |x| x/coordinates.size.to_f }
    centroid.sphere!
    return centroid
  end

  def add(other)
    if(self.size != other.size) then
      raise "Dimension error."
    end
    self.each_index do |idx|
      self[idx] += other[idx]
    end
  end

  def distance_to(other)
    if(self.size != other.size) then
      raise "Dimension error."
    end
    sum = 0
    self.each_index do |idx|
      sum += self[idx] * other[idx]
    end
    return 1 - sum
  end

  def norm
    Math.sqrt(self.inject(0.0) { |acc, e| acc + e*e })
  end

  def sphere!
    norm = self.norm
    self.map! { |x| x/norm } unless norm == 0
  end

  def to_s
    "(#{self.join(", ")})"
  end
end