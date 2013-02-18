module SPCore
class FFT

  # forward FFT transform  
  def self.forward input, force_power_of_two_size = true
    size = input.size
    power_of_two = Math::log2(size)
    if power_of_two.floor != power_of_two # input size is not an even power of two
      if force_power_of_two_size
        new_size = 2**(power_of_two.to_i() + 1)
        input += Array.new(new_size - size, 0.0)
        
        size = input.size
        power_of_two = Math::log2(size)
      else
        raise ArgumentError, "input.size #{size} is not power of 2"
      end
    end
    power_of_two = power_of_two.to_i
    x = bit_reverse_order input, power_of_two
    
    phase = Array.new(size/2){|n|
      Complex(Math::cos(2*Math::PI*n/size), -Math::sin(2*Math::PI*n/size))
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

  private

  def self.get_bit_reversed_addr i, nbits
    i.to_s(2).rjust(nbits, '0').reverse!.to_i(2)
  end
  
  def self.bit_reverse_order input, m
    Array.new(input.size){|i| input[get_bit_reversed_addr(i, m)] }
  end

end
end
