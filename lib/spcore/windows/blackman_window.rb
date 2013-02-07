module SPCore
class BlackmanWindow
  attr_reader :data
  def initialize size
    @data = Array.new size
    alpha = 0.16
    a0 = (1 - alpha) / 2.0
    a1 = 0.5
    a2 = alpha / 2.0
    
    size.times do |n|
      @data[n] = a0 - (a1 * Math::cos((TWO_PI * n)/(size - 1))) + (a2 * Math::cos((FOUR_PI * n)/(size - 1)))
    end
  end
end
end