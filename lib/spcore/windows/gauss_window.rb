module SPCore
class GaussWindow
  attr_reader :data
  def initialize size
    @data = Array.new size
    sigma = 0.4 # must be <= 0.5
    size.times do |n|
      a = (n - (size - 1) / 2) / (sigma * (size - 1) / 2)
      @data[n] = Math::exp(-0.5 * a**2)
    end
  end
end
end