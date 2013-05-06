module SPCore
# Produces a Tukey window of a given size (number of samples).
# The Tukey window, also known as tapered cosine, can be regarded as a cosine
# lobe of width alpha * N / 2 that is convolved with a rectangular window. At
# alpha = 0 it becomes rectangular, and at alpha = 1 it becomes a Hann window.
# For more info, see https://en.wikipedia.org/wiki/Window_function#Tukey_window.
class TukeyWindow
  attr_reader :data
  def initialize size, alpha = 0.5
    @data = Array.new(size)
    
    left = (alpha * (size - 1) / 2.0).to_i
    right = ((size - 1) * (1.0 - (alpha / 2.0))).to_i
    
    size_min_1 = size - 1
    
    for n in 0...left
      x = Math::PI * (((2.0 * n) / (alpha * size_min_1)) - 1.0)
      @data[n] = 0.5 * (1.0 + Math::cos(x))
    end
    
    for n in left..right
      @data[n] = 1.0
    end
    
    for n in (right + 1)...size
      x = Math::PI * (((2 * n) / (alpha * size_min_1)) - (2.0 / alpha) + 1.0)
      @data[n] = 0.5 * (1.0 + Math::cos(x))
    end
  end
end
end