module SPCore
# Perform FFT transforms, forward and inverse.
# @author James Tunnell
class FFT

  def self.power_of_two? size
    log2size = Math::log2(size)
    return log2size.floor == log2size
  end
  
  # Forward Radix-2 FFT transform using decimation-in-time. Operates on an array
  # of real values, representing a time domain signal.
  # Ported from unlicensed MATLAB code which was posted to the MathWorks file
  # exchange by Dinesh Dileep Gaurav.
  # See http://www.mathworks.com/matlabcentral/fileexchange/17778.
  # @param [Array] input An array of numeric values. If size is not an exact
  #                      radix-2 number, then zeros will be appended until it is,
  #                      unless force_radix_2_size is set false.
  # @param force_radix_2_size If true, any input that does not have an exact
  #                           power-of-two size will be appended with zeros
  #                           until it does. Set true by default.
  # @raise [ArgumentError] if input size is not an exact radix-2 number and
  #                        force_radix_2_size is false.
  def self.forward input, force_radix_2_size = true
    size = input.size
    power_of_two = Math::log2(size)
    if power_of_two.floor != power_of_two # input size is not an even power of two
      if force_radix_2_size
        new_size = 2**(power_of_two.to_i() + 1)
        input += Array.new(new_size - size, 0.0)
        
        size = input.size
        power_of_two = Math::log2(size)
      else
        raise ArgumentError, "input.size #{size} is not a radix-2 number"
      end
    end
    power_of_two = power_of_two.to_i
    x = bit_reverse_order input, power_of_two
    
    phase = Array.new(size/2){|n|
      Complex(Math::cos(TWO_PI*n/size), -Math::sin(TWO_PI*n/size))
    }
    for a in 1..power_of_two
      l = 2**a
      phase_level = []

      0.step(size/2, size/l) do |i|
        phase_level << phase[i]
      end
      
      ks = []
      0.step(size-l, l) do |k|
        ks << k
      end

      ks.each do |k|
        for n in 0...l/2
          idx1 = n+k
          idx2 = n+k + (l/2)
          
          first  = x[idx1]
          second = x[idx2] * phase_level[n]
          x[idx1] = first + second
          x[idx2] = first - second
        end
      end
    end
    return x
  end

  # Inverse Radix-2 FFT transform. Operates on an array of complex values, as
  # one would obtain from the forward FFT transform.
  # Ported from unlicensed MATLAB code which was posted to the MathWorks file
  # exchange by Dinesh Dileep Gaurav.
  # See http://www.mathworks.com/matlabcentral/fileexchange/17778.
  # @param [Array] input An array of complex values. Must have a radix-2 size
  #                         (2, 4, 8, 16, 32, ...).
  # @raise [ArgumentError] if input size is not an exact power-of-two.
  def self.inverse input
    size = input.size
    power_of_two = Math::log2(size)
    raise ArgumentError, "input.size #{size} is not power of 2" if power_of_two.floor != power_of_two
    power_of_two = power_of_two.to_i
    x = bit_reverse_order input, power_of_two
    
    phase = Array.new(size/2){|n|
      Complex(Math::cos(TWO_PI*n/size), -Math::sin(TWO_PI*n/size))
    }
    for a in 1..power_of_two
      l = 2**a
      phase_level = []

      0.step(size/2, size/l) do |i|
        phase_level << phase[i]
      end
      
      ks = []
      0.step(size-l, l) do |k|
        ks << k
      end

      ks.each do |k|
        for n in 0...l/2
          idx1 = n+k
          idx2 = n+k + (l/2)
          
          first  = x[idx1]
          second = x[idx2] * phase_level[n]
          x[idx1] = (first + second)
          x[idx2] = (first - second)
        end
      end
    end
    
    return x.map {|val| val / size }
  end

  private

  def self.get_bit_reversed_addr i, nbits
    i.to_s(2).rjust(nbits, '0').reverse!.to_i(2)
  end
  
  def self.bit_reverse_order input, m
    Array.new(input.size){|i| input[get_bit_reversed_addr(i, m)] }
  end

end
end
