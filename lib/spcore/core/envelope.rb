module SPCore
# Determines the envelope of given samples. Unlike the EnvelopeDetector, this
# operates on a signal (time-series data) after it is recieved, not
# sample-by-sample. As a result, it provides the envelope as an entire signal.
#
# @author James Tunnell
class Envelope < Signal
  
  attr_reader :data
  
  def initialize samples
    # combine absolute values of positive maxima and negative minima
    extrema = Extrema.new(samples)
    points = {}
    extrema.minima.each do |idx,val|
      if val <= 0.0
        points[idx] = val.abs
      end
    end
    
    extrema.maxima.each do |idx,val|
      if val >= 0.0
        points[idx] = val.abs
      end
    end
    
    # add in first and last samples so the envelope follows entire signal
    points[0] = samples[0].abs
    points[samples.count - 1] = samples[samples.count - 1].abs
    
    indices = points.keys.sort
    @data = Array.new(samples.count, 0)
    
    # interpolate between all the extrema for the rest of the values. We
    # manually added first/last index so the whole signal should be covered
    # by this
    for i in 1...indices.count
      l_idx = indices[i-1]
      r_idx = indices[i]
      
      l_val = points[l_idx]
      r_val = points[r_idx]
      
      @data[l_idx] = l_val
      @data[r_idx] = r_val
      
      idx_span = r_idx - l_idx
      
      for j in (l_idx + 1)...(r_idx)
        x = (j - l_idx).to_f / idx_span
        y = Interpolation.linear l_val, r_val, x
        @data[j] = y
      end
    end
  end

end
end
