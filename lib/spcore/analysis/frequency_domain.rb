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
  
  # Find the strongest harmonic series among the given peak data.
  def self.harmonic_series peaks, max_partials = 8
    tolerance_perc = 0.1
    series = []
    
    # look for a harmonic series
    peaks.count.times do |i|
      f = peaks.keys[i]
      tolerance_hz = f * tolerance_perc
      harmonics = [ f ]
      
      for n in 2..(max_partials + 1)
        target = n * f
        window = (target - tolerance_hz)..(target + tolerance_hz)
        candidates = peaks.select {|actual,magn| window.include?(actual) }
        
        if candidates.any?
          min = candidates.min_by {|actual,magn| (actual - target).abs }
          harmonics.push min[0]
        end
      end
      
      series.push harmonics
    end
    
    # find the strongest series
    strongest_series = series.max_by do |harmonics|
      harmonics.inject(0) {|energy, harmonic| energy + peaks[harmonic]**2}
    end
    
    return strongest_series
  end
end
end