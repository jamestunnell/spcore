module SPCore
class Scale
  def self.linear range, n_points
    incr = (range.last - range.first) / (n_points - 1)
    points = Array.new(n_points)
    value = range.first
    
    points.each_index do |i|
      points[i] = value
      value += incr
    end
    
    return points
  end
  
  def self.exponential range, n_points
    multiplier = (range.last / range.first)**(1.0/(n_points-1))
    points = Array.new(n_points)
    value = range.first
    
    points.each_index do |i|
      points[i] = value
      value *= multiplier
    end
    
    return points
  end
end
end
