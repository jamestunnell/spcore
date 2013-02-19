module SPCore
# Produces a Hann window of a given size (number of samples).
# For more info, see https://en.wikipedia.org/wiki/Window_function#Hann_.28Hanning.29_window.
class HannWindow
  attr_reader :data
  def initialize size
    @data = Array.new(size)
    size.times do |n|
      @data[n] = 0.5 * (1 - Math::cos((TWO_PI * n)/(size - 1)))
    end
  end
end
end
