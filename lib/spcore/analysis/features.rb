module SPCore
class Features  
  # Returns minima and maxima.
  # @param [true/false] remove_inner_extrema Removes positive minima and negative maxima.
  def self.extrema samples, remove_inner = false
    self.extrema_hash(samples, remove_inner)[:extrema]
  end
  
  # Returns minima.
  # @param [true/false] remove_inner Removes positive minima.
  def self.minima samples, remove_inner = false
    self.extrema_hash(samples, remove_inner)[:minima]
  end

  # Returns maxima.
  # @param [true/false] remove_inner Removes negative maxima.
  def self.maxima samples, remove_inner = false
    self.extrema_hash(samples, remove_inner)[:maxima]
  end  

  def self.envelope samples
    # starting with outer extrema (only positive maxima and negative minima)
    starting_outline = self.extrema(samples, true)
    
    # add in first and last samples so the envelope follows entire signal
    starting_outline[0] = samples[0].abs
    starting_outline[samples.count - 1] = samples[samples.count - 1].abs
    
    # the envelope is only concerned with absolute values
    starting_outline.keys.each do |key|
      starting_outline[key] = starting_outline[key].abs
    end
    
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
    output = PolynomialResampling.upsample(downsampled_outline, upsample_factor)
    
    return output
  end

  private

  # Finds extrema (minima and maxima), return :extrema, :minima, and :maxima
  # seperately in a hash.
  def self.extrema_hash samples, remove_inner = false
    minima = {}
    maxima = {}
    
    global_min_idx = 0
    global_min_val = samples[0]
    global_max_idx = 0
    global_max_val = samples[0]
    
    diffs = []
    for i in (1...samples.count)
      diffs.push(samples[i] - samples[i-1])
      
      if samples[i] < global_min_val
        global_min_idx = i
        global_min_val = samples[i]
      end
      
      if samples[i] > global_max_val
        global_max_idx = i
        global_max_val = samples[i]
      end
    end
    minima[global_min_idx] = global_min_val
    maxima[global_max_idx] = global_max_val
    
    is_positive = diffs.first > 0.0 # starting off with positive difference?
    
    # at zero crossings there is a local maxima/minima    
    for i in (1...diffs.count)
      if is_positive
        # at positive-to-negative transition there is a local maxima
        if diffs[i] <= 0.0
          maxima[i] = samples[i]
          is_positive = false
        end
      else
        # at negative-to-positive transition there is a local minima
        if diffs[i] > 0.0
          minima[i] = samples[i]
          is_positive = true
        end
      end
    end
    
    if remove_inner
      minima.keep_if {|idx,val| val <= 0 }
      maxima.keep_if {|idx,val| val >= 0 }
    end
        
    return :minima => minima, :maxima => maxima, :extrema => minima.merge(maxima)
  end

end
end
