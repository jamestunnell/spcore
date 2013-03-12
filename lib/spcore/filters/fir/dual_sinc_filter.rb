module SPCore

# Extended windowed sinc filter. Implements bandpass and bandstop using
# two SincFilterBase objects.
#
# Theoretical source: http://www.labbookpages.co.uk/audio/firWindowing.html
#
# @author James Tunnell
#
class DualSincFilter
  include Hashmake::HashMakeable
  
  # Use to process hashed args in #initialize.
  ARG_SPECS = {
    :order => arg_spec(:reqd => true, :type => Fixnum, :validator => ->(a){ a % 2 == 0 } ),
    :sample_rate => arg_spec(:reqd => true, :type => Numeric, :validator => ->(a){ a > 0.0 } ),
    :left_cutoff_freq => arg_spec(:reqd => true, :type => Numeric, :validator => ->(a){ a > 0.0 } ),
    :right_cutoff_freq => arg_spec(:reqd => true, :type => Numeric, :validator => ->(a){ a > 0.0 } ),
    :window_class => arg_spec(:reqd => false, :type => Class, :default => BlackmanWindow ),
  }
  
  attr_reader :bandpass_fir, :bandstop_fir, :left_filter, :right_filter
  
  # Given a filter order, 2 cutoff frequencies, sample rate, and window class,
  # develop a FIR filter kernel that can be used for lowpass filtering.
  def initialize args
    hash_make DualSincFilter::ARG_SPECS, args
    
    raise ArgumentError, "left_cutoff_freq is greater than 0.5 * sample_rate" if @left_cutoff_freq > (@sample_rate / 2)
    raise ArgumentError, "right_cutoff_freq is greater than 0.5 * sample_rate" if @right_cutoff_freq > (@sample_rate / 2)
    raise ArgumentError, "left_cutoff_freq is not less than right_cutoff_freq" unless @left_cutoff_freq < @right_cutoff_freq 
    
    @left_filter = SincFilter.new(
      :sample_rate => @sample_rate,
      :order => @order,
      :cutoff_freq => @left_cutoff_freq,
      :window_class => @window_class,
    )

    @right_filter = SincFilter.new(
      :sample_rate => @sample_rate,
      :order => @order,
      :cutoff_freq => @right_cutoff_freq,
      :window_class => @window_class,
    )
    
    size = @order + 1

    # make FIR filter kernels for bandpass and bandstop
    
    bandpass_kernel = Array.new(size)
    bandstop_kernel = Array.new(size)
    window = @window_class.new(size)
    
    for n in 0...(@order / 2)
      bandpass_kernel[size - 1 - n] = bandpass_kernel[n] = @right_filter.lowpass_fir.kernel[n] + @left_filter.highpass_fir.kernel[n]
      bandstop_kernel[size - 1 - n] = bandstop_kernel[n] = @left_filter.lowpass_fir.kernel[n] + @right_filter.highpass_fir.kernel[n]
    end

    left_transition_freq = @left_cutoff_freq / @sample_rate
    right_transition_freq = @right_cutoff_freq / @sample_rate
    bw_times_two = 2.0 * (right_transition_freq - left_transition_freq)
    window_center_val = window.data[@order / 2]
    
    bandpass_kernel[@order / 2] = bw_times_two * window_center_val
    bandstop_kernel[@order / 2] = (1.0 - bw_times_two) * window_center_val
    
    @bandpass_fir = FIR.new bandpass_kernel, @sample_rate
    @bandstop_fir = FIR.new bandstop_kernel, @sample_rate
  end

  # Process the input with the bandpass FIR.
  # @return [Array] containing the filtered input.  
  def bandpass input
    return @bandpass_fir.convolve input
  end
  
  # Process the input with the bandstop FIR.
  # @return [Array] containing the filtered input.
  def bandstop input
    return @bandstop_fir.convolve input
  end
end
end
