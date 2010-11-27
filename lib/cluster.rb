class Cluster
  attr_reader :elements, :centroid
  def initialize(element)
    @elements = []
    @elements << element
    @centroid = element
  end

  def distance_to(element)
    @centroid.distance_to(element)
  end

  def recalculate_centroid
    @centroid = Coordinate.centroid(@elements)
  end

  def add(element)
    @elements << element
    element.cluster = self
  end

  def remove(element)
    @elements.delete(element)
    element.cluster = nil
  end

  def residual_sum_squared
    @elements.inject(0) { |acc, e| acc + e.distance_to(self.centroid)**2 }
  end

  def title
    @elements.min { |a, b| b.distance_to(self.centroid) \
                       <=> a.distance_to(self.centroid) }.data
  end
end