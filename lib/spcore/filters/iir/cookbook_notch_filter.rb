module SPCore
class CookbookNotchFilter < BiquadFilter
  def initialize sample_rate
    super(sample_rate)
  end
  
  def set_critical_freq_and_bw critical_freq, bandwidth
    @critical_freq = critical_freq
    @bandwidth = bandwidth

    # setup variables
    omega = 2.0 * Math::PI * @critical_freq / @sample_rate
    sn = Math::sin(omega)
    cs = Math::cos(omega)
    alpha = sn * Math::sinh(BiquadFilter::LN_2 / 2.0 * @bandwidth * omega / sn)

    b0 = 1.0
    b1 = -2.0 * cs
    b2 = 1.0
    a0 = 1.0 + alpha
    a1 = -2.0 * cs
    a2 = 1.0 - alpha

    # precompute the coefficients
    @biquad.b0 = b0 / a0
    @biquad.b1 = b1 / a0
    @biquad.b2 = b2 / a0
    @biquad.a0 = a0 / a0
    @biquad.a1 = a1 / a0
    @biquad.a2 = a2 / a0

    ## zero initial samples
    #@biquad.x1 = @biquad.x2 = 0
    #@biquad.y1 = @biquad.y2 = 0
  end

end
end
