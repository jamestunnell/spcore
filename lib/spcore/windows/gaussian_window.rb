module SPCore
# Produces a Gaussian window of a given size (number of samples).
# For more info, see https://en.wikipedia.org/wiki/Window_function#Gaussian_windows.
class GaussianWindow
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