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
    
    filter = SincFilter.new(
      :sample_rate => (sample_rate * upsample_factor),
      :order => filter_order,
      :cutoff_freq => (sample_rate / 2),
      :window_class => NuttallWindow
    )
    
    return filter.lowpass(output)
  end

  def self.downsample input, sample_rate, downsample_factor, filter_order
    raise ArgumentError, "input.size is less than four" unless input.size >= 4
    raise ArgumentError, "downsample_factor is not a Fixnum" unless downsample_factor.is_a?(Fixnum)
    raise ArgumentError, "downsample_factor is not greater than 1" unless downsample_factor > 1
    raise ArgumentError, "sample_rate is not greater than 0" unless sample_rate > 0
    
    needed_samples = input.size % downsample_factor
    if needed_samples == 0
      input += Array.new(needed_samples, 0.0)
    end

    filter = SincFilter.new(
      :sample_rate => sample_rate, :order => filter_order,
      :cutoff_freq => ((sample_rate / downsample_factor) / 2.0),
      :window_class => NuttallWindow
    )
    
    filtered = filter.lowpass(input)
    return Array.new(filtered.size / downsample_factor) { |i| filtered[i * downsample_factor] }
  end
  
  def self.resample input, sample_rate, upsample_factor, downsample_factor, filter_order
    raise ArgumentError, "input.size is less than four" unless input.size >= 4
    raise ArgumentError, "upsample_factor is not a Fixnum" unless upsample_factor.is_a?(Fixnum)
    raise ArgumentError, "upsample_factor is not greater than 1" unless upsample_factor > 1
    raise ArgumentError, "downsample_factor is not a Fixnum" unless downsample_factor.is_a?(Fixnum)
    raise ArgumentError, "downsample_factor is not greater than 1" unless downsample_factor > 1
    raise ArgumentError, "sample_rate is not greater than 0" unless sample_rate > 0
    
    upsampled = Array.new((upsample_factor * input.size).to_i, 0.0)
    input.each_index do |i|
      upsampled[i * upsample_factor] = input[i] * upsample_factor
    end

    needed_samples = upsampled.size % downsample_factor
    if needed_samples == 0
      upsampled += Array.new(needed_samples, 0.0)
    end
    
    target_rate = sample_rate * upsample_factor / downsample_factor
    cutoff = (target_rate < sample_rate) ? (target_rate / 2.0) : (sample_rate / 2.0)
    
    filter = SincFilter.new(
      :sample_rate => (sample_rate * upsample_factor), :order => filter_order,
      :cutoff_freq => cutoff, :window_class => NuttallWindow
    )
    filtered = filter.lowpass(upsampled)
    return Array.new(filtered.size / downsample_factor){ |i| filtered[i * downsample_factor] }
  end

end
end
