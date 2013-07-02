module SPCore
# Frequency domain analysis class. On instantiation a forware FFT is performed
# on the given time series data, and the results are stored in full and half form.
# The half-FFT form cuts out the latter half of the FFT results. Also, for the
# half-FFT the complex values will be converted to magnitude (linear or decibel)
# if specified in :fft_format (see FFT_FORMATS for valid values).
class FrequencyDomain
  include Hashmake::HashMakeable
  
  FFT_COMPLEX_VALUED = :complexValued
  FFT_MAGNITUDE_LINEAR = :magnitudeLinear
  FFT_MAGNITUDE_DECIBEL = :magnitudeDecibel
  
  # valid values to give for the :fft_format key.
  FFT_FORMATS = [
    FFT_COMPLEX_VALUED,
    FFT_MAGNITUDE_LINEAR,
    FFT_MAGNITUDE_DECIBEL
  ]
  
  # define how the class is to be instantiated by hash.
  ARG_SPECS = {
    :time_data => arg_spec_array(:reqd => true, :type => Numeric),
    :sample_rate => arg_spec(:reqd => true, :type => Numeric, :validator => ->(a){ a > 0 }),
    :fft_format => arg_spec(:reqd => false, :type => Symbol, :default => FFT_MAGNITUDE_DECIBEL, :validator => ->(a){FFT_FORMATS.include?(a)})
  }
  
  attr_reader :time_data, :sample_rate, :fft_format, :fft_full, :fft_half
  
  def initialize args
    hash_make FrequencyDomain::ARG_SPECS, args
    @fft_full = FFT.forward @time_data
    @fft_half = @fft_full[0...(@fft_full.size / 2)]
    
    case(@fft_format)
    when FFT_MAGNITUDE_LINEAR
      @fft_half = @fft_half.map {|x| x.magnitude }
    when FFT_MAGNITUDE_DECIBEL
      @fft_half = @fft_half.map {|x| Gain.linear_to_db x.magnitude }  # in decibels
    end
  end
  
  # Convert an FFT output index to the corresponding frequency bin
  def idx_to_freq(idx)
    return (idx * @sample_rate.to_f) / @fft_full.size
  end
  
  # Convert an FFT frequency bin to the corresponding FFT output index
  def freq_to_idx(freq)
    return (freq * @fft_full.size) / @sample_rate.to_f
  end
  
  # Find frequency peak values.
  def peaks
    # map positive maxima to indices
    positive_maxima = Features.positive_maxima(@fft_half)

    freq_peaks = {}
    positive_maxima.keys.sort.each do |idx|
      freq = idx_to_freq(idx)
      freq_peaks[freq] = positive_maxima[idx]
    end
    
    return freq_peaks
  end
  
  GCD = :gcd
  WINDOW = :window
  HARMONIC_SERIES_APPROACHES = [ GCD, WINDOW ]
  
  # Find the strongest harmonic series among the given peak data.
  def harmonic_series opts = {}
    defaults = { :n_peaks => 8, :min_freq => 40.0, :approach => WINDOW }
    opts = defaults.merge(opts)
    
    n_peaks = opts[:n_peaks]
    min_freq = opts[:min_freq]
    approach = opts[:approach]
    
    raise ArgumentError, "n_peaks is < 1" if n_peaks < 1
    peaks = self.peaks
    
    if peaks.empty?
      return []
    end
    
    max_freq = peaks.keys.max
    max_idx = freq_to_idx(max_freq)
    
    sorted_pairs = peaks.sort_by {|f,m| m}
    top_n_pairs = sorted_pairs.reverse[0, n_peaks]
    
    candidate_series = []
    
    case approach
    when GCD
      for n in 1..n_peaks
        combinations = top_n_pairs.combination(n).to_a
        combinations.each do |combination|
          freq_indices = combination.map {|pair| freq_to_idx(pair[0]) }
          fund_idx = multi_gcd freq_indices
          
          if fund_idx >= freq_to_idx(min_freq)
            series = []
            idx = fund_idx
            while idx <= max_idx
              freq = idx_to_freq(idx)
              #if peaks.has_key? freq
                series.push freq
              #end
              idx += fund_idx
            end
            candidate_series.push series
          end
        end
      end
    when WINDOW
      # look for a harmonic series
      top_n_pairs.each do |pair|
        f_base = pair[0]
        
        min_idx_base = freq_to_idx(f_base) - 0.5
        max_idx_base = min_idx_base + 1.0
        
        harmonic_series = [ f_base ]
        target = 2 * f_base
        min_idx = 2 * min_idx_base
        max_idx = 2 * max_idx_base
        
        while target < max_freq
          f_l = idx_to_freq(min_idx.floor)
          f_h = idx_to_freq(max_idx.ceil)
          window = f_l..f_h
          candidates = peaks.select {|actual,magn| window.include?(actual) }
          
          if candidates.any?
            min = candidates.min_by {|actual,magn| (actual - target).abs }
            harmonic_series.push min[0]
          else
            break
          end
          
          target += f_base
          min_idx += min_idx_base
          max_idx += max_idx_base
        end
        
        candidate_series.push harmonic_series
      end
    else
      raise ArgumentError, "#{approach} approach is not supported"
    end
    
    strongest_series = candidate_series.max_by do |harmonic_series|
      sum = 0
      harmonic_series.each do |f|
        if peaks.has_key?(f)
          sum += peaks[f]**2
        else
          m = @fft_half[freq_to_idx(f)].magnitude
          sum += m**2
        end
      end
      sum
    end
    
    return strongest_series
  end
  
  private
  
  def gcd a,b
    if b == 0
      return a
    else
      return gcd(b, a % b)
    end
  end
  
  def multi_gcd nums
    if nums.count == 1
      return nums[0]
    elsif nums.count == 2
      return gcd nums[0], nums[1]
    else
      return multi_gcd [gcd(nums[0], nums[1])] + nums[2..-1]
    end
  end
  
end
end