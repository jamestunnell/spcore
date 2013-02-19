module SPCore
# Produces a triangular window of a given size (number of samples).
# Endpoints are near zero. Midpoint is one. There is a linear slope between endpoints and midpoint.
# For more info, see https://en.wikipedia.org/wiki/Window_function#Triangular_window
class TriangularWindow
  attr_reader :data
  def initialize size
    @data = Array.new(size)
    size.times do |n|
      @data[n] = (2.0 / (size + 1)) * (((size + 1) / 2.0) - (n - ((size - 1) / 2.0)).abs)
    end
  end
end
end
