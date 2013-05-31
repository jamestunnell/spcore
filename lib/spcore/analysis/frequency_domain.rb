module SPCore
# Frequency domain analysis methods.
class FrequencyDomain
  # Convert an FFT output index to the corresponding frequency bin
  def self.idx_to_freq(fft_size, sample_rate, idx)
    return (idx * sample_rate.to_f) / fft_size
  end
    
  # Find frequency magnitude peaks. Magnitude is in dB.
  def self.freq_peaks samples, sample_rate, filter_small_peaks = true
    fft_out = FFT.forward samples
    fft_out = fft_out[0...(fft_out.size / 2)]
    fft_out = fft_out.map {|x| Gain.linear_to_db x.magnitude }  # map complex value to magnitude in decibels
    
    fft_size = fft_out.size * 2
    
    # map positive maxima to indices
    maxima = Features.maxima(fft_out, true)
    
    if filter_small_peaks
      # filter out peaks that are not beyond 1 standard dev above mean
      mean = Statistics.mean(fft_out)
      sd = Statistics.std_dev(fft_out)
      
      maxima.keep_if do |idx, magn_db|
        magn_db > (mean + sd)
      end
    end

    freq_peaks = {}
    maxima.keys.sort.each do |idx|
      freq = idx_to_freq(fft_size, sample_rate, idx)
      freq_peaks[freq] = maxima[idx]
    end
    
    return freq_peaks
  end
  
  # Find the fundamental frequency of signal. If there is a single harmonic
  # series present then the fundamental of that series will be returned.
  # Otherwise, the strongest peak found will be returned.
  def self.fundamental samples, sample_rate
    peaks = self.freq_peaks samples, sample_rate, true
    fundamental = nil
    
    freqs = peaks.keys
    
    partials = {}
    
    # look for a harmonic series
    freqs.count.times do |i|
      f = freqs[i]
      ratios = []
      
      for j in (i+1)...freqs.count
        g = freqs[j]
        ratio = g / f
        rounded = ratio.round
        if (ratio - rounded).abs <= 0.2
          ratios.push rounded
        end
      end
      
      partials[f] = ratios
    end
    
    longest_series = partials.max_by {|fund, ratios| ratios.count }
    
    # finding none, return the freq of the strongest peak
    if longest_series[1].empty?
      fundamental = peaks.max_by { |freq, magn_db| magn_db }[0]
    else
      fundamental = longest_series[0]
    end
    
    return fundamental
  end
end
end