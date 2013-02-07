module SPCore
class BartlettWindow
  attr_reader :data
  def initialize size
    @data = Array.new(size)
    size.times do |n|
      @data[n] = (2.0 / (size - 1)) * (((size - 1) / 2.0) - (n - ((size - 1) / 2.0)).abs)
    end
  end
end
end
