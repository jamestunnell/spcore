module SPCore
# Features analysis methods.
class Features  
  # Returns all minima and maxima (including positive minima and negative maxima).
  def self.extrema samples
    remove_inner = false
    self.extrema_hash(samples, remove_inner)[:extrema]
  end

  # Returns outer minima and maxima (excludes positive minima and negative maxima).
  def self.outer_extrema samples
    remove_inner = true
    self.extrema_hash(samples, remove_inner)[:extrema]
  end

  # Returns all minima (including positive minima).
  def self.minima samples
    remove_inner = false
    self.extrema_hash(samples, remove_inner)[:minima]
  end

  # Returns all minima (excludes positive minima).
  def self.negative_minima samples
    remove_inner = true
    self.extrema_hash(samples, remove_inner)[:minima]
  end
  
  # Returns maxima (includes negative maxima).
  def self.maxima samples
    remove_inner = false
    self.extrema_hash(samples, remove_inner)[:maxima]
  end

  # Returns maxima (excludes negative maxima).
  def self.positive_maxima samples
    remove_inner = true
    self.extrema_hash(samples, remove_inner)[:maxima]
  end
  
  # return the n greatest values of the given array of values.
  def self.top_n values, n
    top_n = []
    values.each do |value|
      if top_n.count < n
        top_n.push value
      else
        smaller = top_n.select {|x| x < value}
        if smaller.any?
          top_n.delete smaller.min
          top_n.push value
        end
      end
    end
    return top_n.sort
  end
  
  def self.outline samples
    starting_outline = make_starting_outline samples
    filled_in_outline = fill_in_starting_outline starting_outline, samples.count
    dropsample_factor = (samples.count / starting_outline.count).to_i
    return dropsample_filled_in_outline filled_in_outline, dropsample_factor
  end
  
  def self.envelope samples
    outline = self.outline samples
    upsample_factor = samples.count / outline.count.to_f
    return PolynomialResampling.upsample(outline, upsample_factor)
  end

  private
  
  def self.make_starting_outline samples
    starting_outline = self.outer_extrema(samples)
    
    # add in first and last samples so the envelope follows entire signal
    starting_outline[0] = samples[0].abs
    starting_outline[samples.count - 1] = samples[samples.count - 1].abs
    
    # the envelope is only concerned with absolute values
    starting_outline.keys.each do |key|
      starting_outline[key] = starting_outline[key].abs
    end
    
    return starting_outline
  end
  
  def self.fill_in_starting_outline starting_outline, tgt_count
    # the extrema we have now are probably not spaced evenly. Upsampling at
    # this point would lead to a time-distorted signal. So the next step is to
    # interpolate between all the extrema to make a crude but properly sampled
    # envelope.
    
    proper_outline = Array.new(tgt_count, 0)
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
    
    return proper_outline
  end
  
  # This properly spaces samples in the filled in outline, so as to avoid time
  # distortion after upsampling.
  def self.dropsample_filled_in_outline filled_in_outline, dropsample_factor
    dropsampled_outline = []

    (0...filled_in_outline.count).step(dropsample_factor) do |n|
      dropsampled_outline.push filled_in_outline[n]
    end
    
    return dropsampled_outline
  end
  
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
