module SPCore
class DFT
  def self.forward_dft input
    raise ArgumentError, "input.size is not even" unless (input.size % 2 == 0)
    size = input.size
    f = Array.new(size / 2)  # freq bins
    
    f.each_index do |k|
      real_sum = 0.0
      imag_sum = 0.0
      size.times do |n|
        a = TWO_PI * n * k / size
        real_sum += input[n] * Math::cos(a)
        imag_sum -= input[n] * Math::sin(a)
      end
      f[k] = Math::sqrt(real_sum**2 + imag_sum**2)
      #f[j] = Math::sqrt(first**2).abs + second**2
    end
    
    return f
  end
  
  # copied from http://jvalentino2.tripod.com/dft/index.html
  def self.forward_dft2 input
    raise ArgumentError, "input.size is not even" unless (input.size % 2 == 0)
    size = input.size
    f = Array.new(size / 2)  # freq bins
    
    for j in 0...(size/2)
      first  = 0
      second = 0
      for k in 0...size
        a = (TWO_PI / size) * (j * k)
        first += input[k] * Math.cos(a)
        second += input[k] * Math.sin(a)
      end
      
      f[j] = Math::sqrt(first**2).abs + second**2
      

      # amplitude = 2 * f[j] / size;
      # frequency = j * h / T * sample_rate;
    end
    
    return f
  end
end
end