module SPCore
# Produces a Lanczos window of a given size (number of samples).
# The Lanczos window is used in Lanczos resampling.
# For more info, see https://en.wikipedia.org/wiki/Window_function#Lanczos_window.
class LanczosWindow
  attr_reader :data
  def initialize size
    @data = Array.new size
    sinc = lambda {|x| (Math::sin(Math::PI * x))/(Math::PI * x) }
    size.times do |n|
      @data[n] = sinc.call(((2.0*n)/(size-1)) - 1)
    end
  end
end
end