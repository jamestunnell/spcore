module SPCore
class NuttallWindow
  attr_reader :data
  def initialize size
    @data = Array.new(size)
    a0, a1, a2, a3 = 0.355768, 0.487396, 0.144232, 0.012604
    size.times do |n|
      @data[n] = a0 - a1 * Math::cos((TWO_PI * n)/(size - 1)) + a2 * Math::cos((FOUR_PI * n)/(size - 1)) - a3 * Math::cos((SIX_PI * n)/(size - 1))
    end
  end
end
end
