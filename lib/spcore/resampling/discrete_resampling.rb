module SPCore
# Provide resampling methods (upsampling and downsampling) using
# discrete filtering.
class DiscreteResampling
  
  def self.upsample input, sample_rate, upsample_factor, filter_order
    raise ArgumentError, "input.size is less than four" unless input.size >= 4
    raise ArgumentError, "upsample_factor is not a Fixnum" unless upsample_factor.is_a?(Fixnum)
    raise ArgumentError, "upsample_factor is not greater than 1" unless upsample_factor > 1
    raise ArgumentError, "sample_rate is not greater than 0" unless sample_rate > 0
    
    output = Array.new((upsample_factor * input.size).to_i, 0.0)
    
    input.each_index do |i|
      output[i * upsample_factor] = input[i] * upsample_factor
    end
    
    order = filter_order
    
    filter = SincFilter.new(
      :sample_rate => (sample_rate * upsample_factor),
      :order => order,
      :cutoff_freq => (sample_rate / 2),
      :window_class => NuttallWindow
    )
    
    return filter.lowpass(output)
  end

end
end
