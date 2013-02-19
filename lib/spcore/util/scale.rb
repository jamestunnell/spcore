module SPCore
# Provide methods for generating sequences that scale linearly or exponentially.
class Scale
  # Produce a sequence of values that progresses in a linear fashion.
  # @param [Range] range The start and end values the set should include.
  # @param [Fixnum] n_points The number of points to create for the sequence, including the start and end points.
  # @raise [ArgumentError] if n_points is < 2.
  def self.linear range, n_points
    raise ArgumentError, "n_points is < 2" if n_points < 2
    incr = (range.last - range.first) / (n_points - 1)
    points = Array.new(n_points)
    value = range.first
    
    points.each_index do |i|
      points[i] = value
      value += incr
    end
    
    return points
  end

  # Produce a sequence of values that progresses in an exponential fashion.
  
  # @param [Range] range The start and end values the set should include.
  # @param [Fixnum] n_points The number of points to create for the sequence, including the start and end points.
  # @raise [ArgumentError] if n_points is < 2.  
  def self.exponential range, n_points
    raise ArgumentError, "n_points is < 2" if n_points < 2
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
