module SPCore
# Determines the envelope of given samples. Unlike the EnvelopeDetector, this
# operates on a signal (time-series data) after it is recieved, not
# sample-by-sample. As a result, it provides the envelope as an entire signal.
#
# @author James Tunnell
class Envelope
  
  attr_reader :data
  
  def initialize samples
    # combine absolute values of positive maxima and negative minima
    extrema = Extrema.new(samples)
    starting_outline = {}
    extrema.minima.each do |idx,val|
      if val <= 0.0
        starting_outline[idx] =val.abs
      end
    end
    
    extrema.maxima.each do |idx,val|
      if val >= 0.0
        starting_outline[idx] = val.abs
      end
    end
    
    # add in first and last samples so the envelope follows entire signal
    starting_outline[0] = samples[0].abs
    starting_outline[samples.count - 1] = samples[samples.count - 1].abs
    
    # the extrema we have now are probably not spaced evenly. Upsampling at
    # this point would lead to a time-distorted signal. So the next step is to
    # interpolate between all the extrema to make a crude but properly sampled
    # envelope.
    
    proper_outline = Array.new(samples.count, 0)
    indices = starting_outline.keys.sort
    
    for i in 1...indices.count
      l_idx = indices[i-1]
      r_idx = indices[i]
      
      l_val = starting_outline[l_idx]
      r_val = starting_outline[r_idx]
      
      proper_outline[l_idx] = l_val
      proper_outline[r_idx] = r_val
      
      idx_span = r_idx - l_idx
      
      for j in (l_idx + 1)...(r_idx)
        x = (j - l_idx).to_f / idx_span
        y = Interpolation.linear l_val, r_val, x
        proper_outline[j] = y
      end
    end
    
    # Now downsample by dropping samples, back to the number of starting_outline we had
    # with just the extrema, but this time with samples properly spaced so as
    # to avoid time distortion after upsampling.
    
    downsample_factor = (samples.count / starting_outline.count).to_i
    downsampled_outline = []

    (0...proper_outline.count).step(downsample_factor) do |n|
      downsampled_outline.push proper_outline[n]
    end
    
    # finally, use polynomial interpolation to upsample to the original sample rate.
    
    upsample_factor = samples.count / downsampled_outline.count.to_f
    @data = PolynomialResampling.upsample(downsampled_outline, upsample_factor)
  end

end
end
