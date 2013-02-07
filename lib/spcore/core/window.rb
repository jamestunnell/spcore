module SPCore

class Window
  RECTANGLE = :windowRectangle
  HANN = :windowHann
  HAMMING = :windowHamming
  COSINE = :windowCosine
  LANCZOS = :windowLanczos
  TRIANGLE = :windowTriangle
  BARTLETT = :windowBartlett
  GAUSS = :windowGauss
  BARTLETT_HANN = :windowBartlettHann
  BLACKMAN = :windowBlackman
  NUTTALL = :windowNuttall
  BLACKMAN_HARRIS = :windowBlackmanHarris
  BLACKMAN_NUTTALL = :windowBlackmanNuttall
  FLAT_TOP = :flatTop
  
  TYPES = [
    # High and moderate resolution windows
    RECTANGLE,
    HANN,
    HAMMING,
    COSINE,
    LANCZOS,
    TRIANGLE,
    BARTLETT,
    GAUSS,
    BARTLETT_HANN,
    BLACKMAN,
    # low resolution windows
    NUTTALL,
    BLACKMAN_HARRIS,
    BLACKMAN_NUTTALL,
    FLAT_TOP
  ]
  
  attr_reader :data, :type
  
  def initialize size, window_type
    raise ArgumentError, "window_type #{window_type} is not one of TYPES" unless TYPES.include? window_type
    
    four_pi = Math::PI * 4.0
    six_pi = Math::PI * 6.0
    eight_pi = Math::PI * 8.0
    @data = Array.new(size)
    
    case window_type
    when RECTANGLE
      size.times do |n|
        @data[n] = 1.0
      end
    when HANN
      size.times do |n|
        @data[n] = 0.5 * (1 - Math::cos((TWO_PI * n)/(size - 1)))
      end
    when HAMMING
      alpha = 0.54
      beta = 1.0 - alpha
      
      size.times do |n|
        @data[n] = alpha - (beta * Math::cos((TWO_PI * n) / (size - 1)))
      end
    when COSINE
      size.times do |n|
        @data[n] = Math::sin((Math::PI * n)/(size - 1))
      end
    when LANCZOS
      sinc = lambda {|x| (Math::sin(Math::PI * x))/(Math::PI * x) }
      size.times do |n|
        @data[n] = sinc.call(((2.0*n)/(size-1)) - 1)
      end
    when TRIANGLE
      size.times do |n|
        @data[n] = (2.0 / (size + 1)) * (((size + 1) / 2.0) - (n - ((size - 1) / 2.0)).abs)
      end    
    when BARTLETT
      size.times do |n|
        @data[n] = (2.0 / (size - 1)) * (((size - 1) / 2.0) - (n - ((size - 1) / 2.0)).abs)
      end
    when GAUSS
      sigma = 0.4 # must be <= 0.5
      size.times do |n|
        a = (n - (size - 1) / 2) / (sigma * (size - 1) / 2)
        @data[n] = Math::exp(-0.5 * a**2)
      end      
    when BARTLETT_HANN
      a0, a1, a2 = 0.62, 0.48, 0.38
      
      size.times do |n|
        @data[n] = a0 - (a1 * ((n.to_f / (size - 1)) - 0.5).abs) - (a2 * Math::cos((TWO_PI * n)/(size - 1)))
      end
    when BLACKMAN
      alpha = 0.16
      a0 = (1 - alpha) / 2.0
      a1 = 0.5
      a2 = alpha / 2.0
      
      size.times do |n|
        @data[n] = a0 - (a1 * Math::cos((TWO_PI * n)/(size - 1))) + (a2 * Math::cos((four_pi * n)/(size - 1)))
      end
    when NUTTALL
      a0, a1, a2, a3 = 0.355768, 0.487396, 0.144232, 0.012604
      size.times do |n|
        @data[n] = a0 - a1 * Math::cos((TWO_PI * n)/(size - 1)) + a2 * Math::cos((four_pi * n)/(size - 1)) - a3 * Math::cos((six_pi * n)/(size - 1))
      end
    when BLACKMAN_HARRIS
      a0, a1, a2, a3 = 0.35875, 0.48829, 0.14128, 0.01168
      size.times do |n|
        @data[n] = a0 - a1 * Math::cos((TWO_PI * n)/(size - 1)) + a2 * Math::cos((four_pi * n)/(size - 1)) - a3 * Math::cos((six_pi * n)/(size - 1))
      end
    when BLACKMAN_NUTTALL
      a0, a1, a2, a3 = 0.3635819, 0.4891775, 0.1365995, 0.0106411
      size.times do |n|
        @data[n] = a0 - a1 * Math::cos((TWO_PI * n)/(size - 1)) + a2 * Math::cos((four_pi * n)/(size - 1)) - a3 * Math::cos((six_pi * n)/(size - 1))
      end
    when FLAT_TOP
      a0, a1, a2, a3, a4 = 1.0, 1.93, 1.29, 0.388, 0.032      
      size.times do |n|
        @data[n] = a0 - a1 * Math::cos((TWO_PI * n)/(size - 1)) + a2 * Math::cos((four_pi * n)/(size - 1)) - a3 * Math::cos((six_pi * n)/(size - 1)) + a4 * Math::cos((eight_pi * n)/(size - 1))
      end
    end
  end

end

end
