module SPCore

# Based on the "simple implementation of Biquad filters" by Tom St Denis,
# which is based on the work "Cookbook formulae for audio EQ biquad filter
# coefficients" by Robert Bristow-Johnson, pbjrbj@viconet.com  a.k.a.
# robert@audioheads.com. Available on the web at
# http://www.smartelectronix.com/musicdsp/text/filters005.txt
class BiquadFilter

  # used in subclasses to calculate IIR filter coefficients
  LN_2 = Math::log(2)

  # this holds the data required to update samples thru a filter
  Struct.new("BiquadState", :b0, :b1, :b2, :a0, :a1, :a2, :x1, :x2, :y1, :y2)

  # A new instance of BiquadFilter.
  # @param [Numeric] sample_rate The sample rate to use in calculating coefficients.
  def initialize sample_rate
    @sample_rate = sample_rate
    @biquad = Struct::BiquadState.new(0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0)
    @critical_freq = 0.0
    @bandwidth = 0.0
  end

  # Set the filter critical frequency and bandwidth. 
  def set_critical_freq_and_bw critical_freq, bandwidth
    raise NotImplementedError, "set_critical_freq_and_bW should be implemented in the derived class!"
  end
  
  # Set the filter critical frequency. 
  def critical_freq= critical_freq
    set_critical_freq_and_bw(critical_freq, @bandwidth);
  end

  # Set the filter bandwidth. 
  def bandwidth= bandwidth
    set_critical_freq_and_bw(@critical_freq, bandwidth);
  end
  
  # Calculate biquad output using Direct Form I:
  #
  # y[n] = (b0/a0)*x[n] + (b1/a0)*x[n-1] + (b2/a0)*x[n-2]
  #                     - (a1/a0)*y[n-1] - (a2/a0)*y[n-2]
  #
  # Note: coefficients are already divided by a0 when they 
  # are calculated. So that step is left out during processing.
  #
  def process_sample sample
    # compute result
    result = @biquad.b0 * sample + @biquad.b1 * @biquad.x1 + @biquad.b2 * @biquad.x2 -
        @biquad.a1 * @biquad.y1 - @biquad.a2 * @biquad.y2;

    # shift x1 to x2, sample to x1
    @biquad.x2 = @biquad.x1;
    @biquad.x1 = sample;

    # shift y1 to y2, result to y1
    @biquad.y2 = @biquad.y1;
    @biquad.y1 = result;

    return result
  end

  # Calculate the frequency magnitude response for the given frequency.
  # @param [Numeric] test_freq The frequency to calculate magnitude response at.
  def get_freq_magnitude_response test_freq
    # Method for determining freq magnitude response is from:
    # http://rs-met.com/documents/dsp/BasicDigitalFilters.pdf
    omega = 2.0 * Math::PI * test_freq / @sample_rate
    b0, b1, b2 = @biquad.b0, @biquad.b1, @biquad.b2
    a0, a1, a2 = 1, @biquad.a1, @biquad.a2
    b = (b0**2) + (b1**2) + (b2**2) + (2 * (b0 * b1 + b1 * b2) * Math::cos(omega)) + (2 * b0 * b2 * Math::cos(2 * omega))
    a = (a0**2) + (a1**2) + (a2**2) + (2 * (a0 * a1 + a1 * a2) * Math::cos(omega)) + (2 * a0 * a2 * Math::cos(2 * omega))
    return Math::sqrt(b/a)
  end

end

end
