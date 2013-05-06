module SPCore
# Finds extrema (minima and maxima).
class Extrema
  
  attr_reader :minima, :maxima, :extrema
  
  def initialize samples
    @minima = {}
    @maxima = {}
    
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
    @minima[global_min_idx] = global_min_val
    @maxima[global_max_idx] = global_max_val
    
    is_positive = diffs.first > 0.0 # starting off with positive difference?
    
    # at zero crossings there is a local maxima/minima    
    for i in (1...diffs.count)
      if is_positive
        # at positive-to-negative transition there is a local maxima
        if diffs[i] <= 0.0
          @maxima[i] = samples[i]
          is_positive = false
        end
      else
        # at negative-to-positive transition there is a local minima
        if diffs[i] > 0.0
          @minima[i] = samples[i]
          is_positive = true
        end
      end
    end
    
    @extrema = @minima.merge(@maxima)    
  end
end 
end
