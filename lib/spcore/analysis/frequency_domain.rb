module SPCore
# Frequency domain analysis methods.
class FrequencyDomain
  # Convert an FFT output index to the corresponding frequency bin
  def self.idx_to_freq(fft_size, sample_rate, idx)
    return (idx * sample_rate.to_f) / fft_size
  end
  
  # Convert an FFT frequency bin to the corresponding FFT output index
  def self.freq_to_idx(fft_size, sample_rate, freq)
    return (freq * fft_size ) / sample_rate.to_f
  end
  
  # Find frequency magnitude peaks. Magnitude is in dB.
  def self.peaks samples, sample_rate
    fft_out = FFT.forward samples
    fft_out = fft_out[0...(fft_out.size / 2)]
    fft_out = fft_out.map {|x| Gain.linear_to_db x.magnitude }  # map complex value to magnitude in decibels
    
    fft_size = fft_out.size * 2
    
    # map positive maxima to indices
    maxima = Features.maxima(fft_out, true)

    freq_peaks = {}
    maxima.keys.sort.each do |idx|
      freq = idx_to_freq(fft_size, sample_rate, idx)
      freq_peaks[freq] = maxima[idx]
    end
    
    return freq_peaks
  end
  
  # Find the fundamental frequency of a set of samples. Picks the fundamental for
  # the series with the highest total energy.
  def self.fundamental samples, sample_rate
    peaks = self.peaks samples, sample_rate
    
    tolerance = 0.1
    n_partials = 8
    partials = {}
    
    # look for a harmonic series
    peaks.count.times do |i|
      f = peaks.keys[i]
      ratios = []
      
      n_partials.times do |n|
        g = n * f
        min = peaks.min_by {|h,magn| (h - g).abs }
        
        ratio = min[0] / f
        percent_error = (ratio - n).abs / n
        
        if percent_error <= tolerance
          ratios.push ratio
        end
      end
      
      # TODO - there may be multiple ratios within the tolerance.
      # In that case, choose the strongest.
      
      partials[f] = ratios
    end
    
    fundamentals = {}
    
    # find the strongest series
    partials.each do |fund,ratios|
      energy = peaks[fund]**2
      
      ratios.each do |ratio|
        energy += peaks[ratio * fund]**2
      end
      
      fundamentals[fund] = energy
    end
    
    max = fundamentals.max_by {|fund, energy| energy}
    return max[0]
  end
end
end