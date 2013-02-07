module SPCore
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
