require 'pry'
module SPCore

# Base windowed sinc filter. Implements lowpass and highpass. A bandpass
# and bandstop filter would be implemented using two of these.
#
# Theoretical source: http://www.labbookpages.co.uk/audio/firWindowing.html
#
# @author James Tunnell
#
class SincFilter
  include Hashmake::HashMakeable

  # Use to process hashed args in #initialize.  
  ARG_SPECS = {
    :order => arg_spec(:reqd => true, :type => Fixnum, :validator => ->(a){ a % 2 == 0 } ),
    :sample_rate => arg_spec(:reqd => true, :type => Fixnum, :validator => ->(a){ a > 0 } ),
    :cutoff_freq => arg_spec(:reqd => true, :type => Numeric, :validator => ->(a){ a > 0.0 } ),
    :window_class => arg_spec(:reqd => false, :type => Class, :default => BlackmanWindow ),
  }
  
  attr_reader :lowpass_fir, :highpass_fir
  
  # Given a filter order, cutoff frequency, sample rate, and window class,
  # develop a FIR filter kernel that can be used for lowpass filtering.
  def initialize args
    hash_make args, SincFilter::ARG_SPECS
    
    raise ArgumentError, "cutoff_freq is greater than 0.5 * sample_rate" if @cutoff_freq > (@sample_rate / 2.0)
    
    size = @order + 1
    transition_freq = @cutoff_freq.to_f / @sample_rate
    b = TWO_PI * transition_freq
    
    # make FIR filter kernels for lowpass and highpass
    
    lowpass_kernel = Array.new(size)
    highpass_kernel = Array.new(size)
    window = @window_class.new(size)
    
    for n in 0...(@order / 2)
      c = n - (@order / 2)
      y = Math::sin(b * c) / (Math::PI * (c))
      lowpass_kernel[size - 1 - n] = lowpass_kernel[n] = y * window.data[n]
      highpass_kernel[size - 1 - n] = highpass_kernel[n] = -lowpass_kernel[n]
    end
    lowpass_kernel[@order / 2] = 2 * transition_freq * window.data[@order / 2]
    highpass_kernel[@order / 2] = (1 - 2 * transition_freq) * window.data[@order / 2]
    
    @lowpass_fir = FIR.new lowpass_kernel, @sample_rate
    @highpass_fir = FIR.new highpass_kernel, @sample_rate
  end
  
  # Process the input with the lowpass FIR.
  # @return [Array] containing the filtered input.
  def lowpass input
    return @lowpass_fir.convolve input
  end
  
  # Process the input with the highpass FIR.
  # @return [Array] containing the filtered input.
  def highpass input
    return @highpass_fir.convolve input
  end
end


end
