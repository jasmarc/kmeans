require "cluster"

class KMeans
  def initialize(elements, k)
    @elements, @k = elements, k
    @clusters = []
    @elements.shuffle.first(k).each do |element|
      @clusters << Cluster.new(element)
    end
  end

  def compute
    begin
      centroids = @clusters.map { |x| x.centroid }
      @elements.each do |element|
        assign_to_cluster(element)
      end
      threads = []
      @clusters.each do |cluster|
        threads << Thread.new(cluster) do |c|
          c.recalculate_centroid
        end
      end
      threads.each {|t| t.join}
    end until(centroids == @clusters.map { |x| x.centroid })
    return @clusters
  end
  
  def to_s
    ret = "===\n"
    sums = 0
    @clusters.each do |cluster|
      rss = cluster.residual_sum_squared
      sums += rss
      ret += "cluster (#{rss}) #{cluster.title}:\n"
      cluster.elements.each do |element|
        ret += element.data.to_s + "\n"
      end
    end
    return ret
  end
  
  def residual_sum_squared
    @clusters.inject(0) { |acc, e| acc + e.residual_sum_squared }
  end

:private
  def assign_to_cluster(element)
    cur_cluster = element.cluster
    new_cluster = @clusters.min do |a, b|
      a.distance_to(element) <=> b.distance_to(element)
    end
    if(!cur_cluster.nil?)
      cur_cluster.remove(element)
    end
    new_cluster.add(element)
  end
end