module SPCore
# Produces a triangular window of a given size (number of samples).
# Endpoints are zero. Midpoint is one. There is a linear slope between endpoints and midpoint.
class BartlettWindow
  attr_reader :data
  def initialize size
    @data = Array.new(size)
    size.times do |n|
      @data[n] = (2.0 / (size - 1)) * (((size - 1) / 2.0) - (n - ((size - 1) / 2.0)).abs)
    end
  end
end
end
