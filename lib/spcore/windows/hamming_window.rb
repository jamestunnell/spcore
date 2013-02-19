module SPCore
# Produces a Hamming window of a given size (number of samples).
# For more info, see https://en.wikipedia.org/wiki/Window_function#Hamming_window.
class HammingWindow
  attr_reader :data
  def initialize size
    @data = Array.new size
    alpha = 0.54
    beta = 1.0 - alpha
      
    size.times do |n|
      @data[n] = alpha - (beta * Math::cos((TWO_PI * n) / (size - 1)))
    end
  end
end
end