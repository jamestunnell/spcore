module SPCore
class DFT
  # @param [Array] input  array of real values, representing the time domain
  #                       signal to be passed into the forward DFT.
  def self.forward input, skip_second_half = false
    input_size = input.size
    raise ArgumentError, "input.size is not even" unless (input_size % 2 == 0)
    
    output_size = input_size
    if skip_second_half
      output_size /= 2
    end
    output = Array.new(output_size)
    
    #(output_size / 2).times do |k|
    output.each_index do |k|
      sum = Complex(0.0)
      input.each_index do |n|
        a = TWO_PI * n * k / input_size
        b = Complex(input[n] * Math::cos(a), -input[n] * Math::sin(a))
        sum += b
      end
      output[k] = sum
      #output[output_size - 1 - k] = output[k] = sum
    end
    
    return output
  end
  
  # @param [Array] input  array of complex values, representing the frequency domain
  #                       signal obtained from the forward DFT.
  def self.inverse input
    input_size = input.size
    raise ArgumentError, "input.size is not even" unless (input_size % 2 == 0)
    
    output = Array.new(input_size)
    output_size = output.size
    
    output.each_index do |k|
      sum = 0.0
      input.each_index do |n|
        a = TWO_PI * n * k / input_size
        sum += input[n].real * Math::cos(a)
        sum += input[n].imag * Math::sin(a)
      end
      output[k] = sum / output_size
    end
    
    return output    
  end
end
end