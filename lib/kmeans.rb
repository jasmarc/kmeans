require "cluster"

class KMeans
  def initialize(elements, k)
    @elements, @k = elements, k
    @clusters = []

    # We start by shuffling and assigning the first k elements to
    # each of our k clusters
    @elements.shuffle.first(k).each do |element|
      @clusters << Cluster.new(element)
    end
  end

  def compute
    begin
      # get the centroids of our clusters
      centroids = @clusters.map { |x| x.centroid }

      # iterate through all the elements and assign
      # to the centroid its closest to
      @elements.each do |element|
        assign_to_cluster(element)
      end

      # recalculate all the centroids (using threads for speed)
      threads = []
      @clusters.each do |cluster|
        threads << Thread.new(cluster) do |c|
          c.recalculate_centroid
        end
      end
      threads.each {|t| t.join}

    # we quit this whole thing when the centroids haven't moved
    end until(centroids == @clusters.map { |x| x.centroid })

    # now return the clusters
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

  # this computes the sum of the RSS values for each cluster
  def residual_sum_squared
    @clusters.inject(0) { |acc, e| acc + e.residual_sum_squared }
  end

:private
  # given an element, assign it to the cluster whose centroid
  # it is closest to
  def assign_to_cluster(element)
    # this is the current cluster
    cur_cluster = element.cluster
    
    # the new cluster is the one it's the closest to
    new_cluster = @clusters.min do |a, b|
      a.distance_to(element) <=> b.distance_to(element)
    end
    
    if(!cur_cluster.nil?)
      # remove it from the old
      cur_cluster.remove(element)
    end
    # and add it to the new
    new_cluster.add(element)
  end
end