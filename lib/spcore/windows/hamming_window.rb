module SPCore
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