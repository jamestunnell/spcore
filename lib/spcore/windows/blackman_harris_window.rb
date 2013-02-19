module SPCore
# Produces a Blackman-Harris window of a given size (number of samples).
# For more info, see https://en.wikipedia.org/wiki/Window_function#Blackman.E2.80.93Harris_window.
class BlackmanHarrisWindow
  attr_reader :data
  def initialize size
    @data = Array.new(size)
    a0, a1, a2, a3 = 0.35875, 0.48829, 0.14128, 0.01168
    size.times do |n|
      @data[n] = a0 - a1 * Math::cos((TWO_PI * n)/(size - 1)) + a2 * Math::cos((FOUR_PI * n)/(size - 1)) - a3 * Math::cos((SIX_PI * n)/(size - 1))
    end
  end
end
end
