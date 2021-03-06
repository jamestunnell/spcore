module SPCore
# Produces a Bartlett-Hann window of a given size (number of samples).
# For more info, see https://en.wikipedia.org/wiki/Window_function#Bartlett.E2.80.93Hann_window.
class BartlettHannWindow
  attr_reader :data
  def initialize size
    @data = Array.new(size)
    a0, a1, a2 = 0.62, 0.48, 0.38
    
    size.times do |n|
      @data[n] = a0 - (a1 * ((n.to_f / (size - 1)) - 0.5).abs) - (a2 * Math::cos((TWO_PI * n)/(size - 1)))
    end
  end
end
end
