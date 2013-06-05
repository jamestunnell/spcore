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
    maxima = Features.maxima(@fft_half, true)

    freq_peaks = {}
    maxima.keys.sort.each do |idx|
      freq = idx_to_freq(idx)
      freq_peaks[freq] = maxima[idx]
    end
    
    return freq_peaks
  end
  
  # Find the strongest harmonic series among the given peak data.
  def harmonic_series
    peaks = self.peaks
    
    max_tries = 10
    max_freq = peaks.keys.max
    
    sorted_pairs = peaks.sort_by {|f,m| m}
    tries = sorted_pairs.count > max_tries ? max_tries : sorted_pairs.count
    
    candidate_series = []
    
    # look for a harmonic series
    sorted_pairs.reverse[0...tries].each do |pair|
      f = pair[0]
      tolerance_hz = 2 * idx_to_freq(1)
      harmonic_series = [ f ]
      
      target = 2 * f
      while target <= max_freq
        window = (target - tolerance_hz)..(target + tolerance_hz)
        candidates = peaks.select {|actual,magn| window.include?(actual) }
        
        if candidates.any?
          min = candidates.min_by {|actual,magn| (actual - target).abs }
          harmonic_series.push min[0]
        else
          break
        end
        
        target += f
      end
      
      candidate_series.push harmonic_series
    end
    
    strongest_series = candidate_series.max_by do |harmonic_series|
      sum = 0
      harmonic_series.each do |freq|
        sum += peaks[freq] * peaks[freq]
      end
      sum
    end
    
    return strongest_series
  end
end
end