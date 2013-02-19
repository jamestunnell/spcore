module SPCore
# Provide resampling methods (upsampling and downsampling) using
# polynomial interpolation.
class PolynomialResampling
  
  def self.upsample input, sample_rate, upsample_factor
    raise ArgumentError, "input.size is less than four" unless input.size >= 4
    raise ArgumentError, "upsample_factor is not greater than 1" unless upsample_factor > 1
    raise ArgumentError, "sample_rate is not greater than 0" unless sample_rate > 0
    
    output = Array.new((upsample_factor * input.size).to_i)
    
    input_size_f = input.size.to_f
    input_size_minus_1 = input.size - 1
    input_size_minus_2 = input.size - 2
    output_size_f = output.size.to_f
    output.each_index do |i|
      
      i_f = i.to_f
      index_into_input = (i_f / output_size_f) * input_size_f
      index_into_input_i = index_into_input.to_i
      
      if(index_into_input <= 1.0) # before second sample
        point1 = input[0]
        point2 = input[0]
        point3 = input[1]
        point4 = input[2]
        x = index_into_input
        output[i] = Interpolation.cubic_hermite(point1, point2, point3, point4, x)
      elsif(index_into_input >= input_size_minus_1) # past last sample
        point1 = input[input_size_minus_1 - 1]
        point2 = input[input_size_minus_1]
        point3 = input[input_size_minus_1]
        point4 = input[input_size_minus_1]
        x = index_into_input - index_into_input.floor
        output[i] = Interpolation.cubic_hermite(point1, point2, point3, point4, x)
      elsif(index_into_input >= input_size_minus_2)  # past second-to-last sample
        point1 = input[index_into_input_i - 1]
        point2 = input[index_into_input_i]
        point3 = input[input_size_minus_1]
        point4 = input[input_size_minus_1]
        x = index_into_input - index_into_input.floor
        output[i] = Interpolation.cubic_hermite(point1, point2, point3, point4, x)
      else # general case
        point1 = input[index_into_input_i - 1]
        point2 = input[index_into_input_i]
        point3 = input[index_into_input_i + 1]
        point4 = input[index_into_input_i + 2]
        x = index_into_input - index_into_input.floor
        output[i] = Interpolation.cubic_hermite(point1, point2, point3, point4, x)
      end
    end
  end
  
end
end