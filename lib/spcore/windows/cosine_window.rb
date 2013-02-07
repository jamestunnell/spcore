module SPCore
class CosineWindow
  attr_reader :data
  def initialize size
    @data = Array.new size
    size.times do |n|
      @data[n] = Math::sin((Math::PI * n)/(size - 1))
    end
  end
end
end