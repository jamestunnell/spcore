module SPCore
# Produces a Cosine window of a given size (number of samples).
# For more info, see https://en.wikipedia.org/wiki/Window_function#Cosine_window.
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