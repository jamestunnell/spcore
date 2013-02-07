module SPCore
class RectangleWindow
  attr_reader :data
  def initialize size
    @data = Array.new(size, 1.0)
  end
end
end
