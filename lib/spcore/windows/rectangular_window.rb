module SPCore
# Produces a rectangular window (all ones) of a given size (number of samples).
# For more info, see https://en.wikipedia.org/wiki/Window_function#Rectangular_window.
class RectangularWindow
  attr_reader :data
  def initialize size
    @data = Array.new(size, 1.0)
  end
end
end
