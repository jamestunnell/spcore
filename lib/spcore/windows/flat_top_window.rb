module SPCore
# Produces a flat top window of a given size (number of samples).
# A flat top window is a partially negative-valued window that has a flat top in
# the frequency domain. They are designed to have a broader bandwidth and so have
# a poorer frequency resolution, leading to low amplitude measurement error suitable
# for use in in spectrum analyzers for the measurement of amplitudes of sinusoidal
# frequency components
# For more info, see https://en.wikipedia.org/wiki/Window_function#Flat_top_window.
class FlatTopWindow
  attr_reader :data
  def initialize size
    @data = Array.new(size)
    a0, a1, a2, a3, a4 = 1.0, 1.93, 1.29, 0.388, 0.032
    
    size.times do |n|
      @data[n] = a0 - a1 * Math::cos((TWO_PI * n)/(size - 1)) + a2 * Math::cos((FOUR_PI * n)/(size - 1)) - a3 * Math::cos((SIX_PI * n)/(size - 1)) + a4 * Math::cos((EIGHT_PI * n)/(size - 1))
    end
    
    max = @data.max
    
    # normalize to max of 1.0
    @data.each_index do |i|
      @data[i] /= max
    end
  end
end
end
