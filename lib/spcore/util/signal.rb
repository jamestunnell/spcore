module SPCore
# Store signal data and provide some useful methods for working with
# (testing and analyzing) the data.
#
# @author James Tunnell
class Signal
  include Hashmake::HashMakeable
  
  # Used to process hashed arguments in #initialize.
  ARG_SPECS = {
    :data => arg_spec(:reqd => true, :type => Array, :validator => ->(a){ a.any? }),
    :sample_rate => arg_spec(:reqd => true, :type => Numeric, :validator => ->(a){ a > 0.0 }),
    #:fft_format => arg_spec(:reqd => false, :type => Symbol, :default => FFT_MAGNITUDE_DECIBEL, :validator => ->(a){FFT_FORMATS.include?(a)})
  }
  
  attr_reader :data, :sample_rate

  # A new instance of Signal.
  #
  # @param [Hash] hashed_args Hashed arguments. Required keys are :data and
  #                           :sample_rate. See ARG_SPECS for more details.
  def initialize hashed_args
    hash_make hashed_args, Signal::ARG_SPECS
  end
  
  # Produce a new Signal object with the same data.
  def clone
    new = Signal.new(:data => @data.clone, :sample_rate => @sample_rate)
    new.instance_variable_set(:@frequency_domain, @frequency_domain)
    return new
  end
  
  # Produce a new Signal object with a subset of the current signal data.
  # @param [Range] range Used to pick the data range.
  def subset range
    new = Signal.new(:data => @data[range], :sample_rate => @sample_rate)
    new.instance_variable_set(:@frequency_domain, @frequency_domain)
    return new
  end
  
  # Size of the signal data.
  def size
    @data.size
  end

  # Size of the signal data.
  def count
    @data.size
  end
  
  # Signal duration in seconds.
  def duration
    return @data.size.to_f / @sample_rate
  end
  
  # Access signal data.
  def [](arg)
    @data[arg]
  end

  # Plot the signal data against sample numbers.
  def plot_1d
    plotter = Plotter.new(:title => "Signal: values vs. sample number", :xtitle => "sample number", :ytitle => "sample value")
    plotter.plot_1d "signal data" => @data
  end
  
  # Plot the signal data against time.
  def plot_2d
    plotter = Plotter.new(:title => "Signal: values vs. time", :xtitle => "time (sec)", :ytitle => "sample value")
    
    data_vs_time = {}
    sp = 1.0 / @sample_rate
    @data.each_index do |i|
      data_vs_time[i * sp] = @data[i]
    end
      
    plotter.plot_2d "signal data" => data_vs_time
  end
  
  # Run a discrete lowpass filter over the signal data (using SincFilter).
  # Modifies current object.
  def lowpass! cutoff_freq, order
    filter = SincFilter.new(:sample_rate => @sample_rate, :order => order, :cutoff_freq => cutoff_freq)
    @data = filter.lowpass(@data)
    return self
  end
  
  # Run a discrete lowpass filter over the signal data (using SincFilter).
  # Return result in a new Signal object.
  def lowpass cutoff_freq, order
    self.clone.lowpass! cutoff_freq, order
  end

  # Run a discrete highpass filter over the signal data (using SincFilter).
  # Modifies current object.
  def highpass! cutoff_freq, order
    filter = SincFilter.new(:sample_rate => @sample_rate, :order => order, :cutoff_freq => cutoff_freq)
    @data = filter.highpass(@data)
    return self
  end
  
  # Run a discrete highpass filter over the signal data (using SincFilter).
  # Return result in a new Signal object.
  def highpass cutoff_freq, order
    self.clone.highpass! cutoff_freq, order
  end
  
  # Run a discrete bandpass filter over the signal data (using DualSincFilter).
  # Modifies current object.
  def bandpass! left_cutoff, right_cutoff, order
    filter = DualSincFilter.new(
      :sample_rate => @sample_rate,
      :order => order,
      :left_cutoff_freq => left_cutoff,
      :right_cutoff_freq => right_cutoff
    )
    @data = filter.bandpass(@data)
    return self
  end
  
  # Run a discrete bandpass filter over the signal data (using DualSincFilter).
  # Return result in a new Signal object.
  def bandpass left_cutoff, right_cutoff, order
    self.clone.bandpass! left_cutoff, right_cutoff, order
  end

  # Run a discrete bandstop filter over the signal data (using DualSincFilter).
  # Modifies current object.
  def bandstop! left_cutoff, right_cutoff, order
    filter = DualSincFilter.new(
      :sample_rate => @sample_rate,
      :order => order,
      :left_cutoff_freq => left_cutoff,
      :right_cutoff_freq => right_cutoff
    )
    @data = filter.bandstop(@data)
    return self
  end
  
  # Run a discrete bandstop filter over the signal data (using DualSincFilter).
  # Return result in a new Signal object.
  def bandstop left_cutoff, right_cutoff, order
    self.clone.bandstop! left_cutoff, right_cutoff, order
  end

  # Increase the sample rate of signal data by the given factor using
  # discrete upsampling method. Modifies current object.
  # @param [Fixnum] upsample_factor Increase the sample rate by this factor.
  # @param [Fixnum] filter_order The filter order for the discrete lowpass filter.
  def upsample_discrete! upsample_factor, filter_order
    @data = DiscreteResampling.upsample @data, @sample_rate, upsample_factor, filter_order
    @sample_rate *= upsample_factor
    return self
  end

  # Increase the sample rate of signal data by the given factor using
  # discrete upsampling method. Return result in a new Signal object.
  # @param [Fixnum] upsample_factor Increase the sample rate by this factor.
  # @param [Fixnum] filter_order The filter order for the discrete lowpass filter.
  def upsample_discrete upsample_factor, filter_order
    return self.clone.upsample_discrete!(upsample_factor, filter_order)
  end

  # Decrease the sample rate of signal data by the given factor using
  # discrete downsampling method. Modifies current object.
  # @param [Fixnum] downsample_factor Decrease the sample rate by this factor.
  # @param [Fixnum] filter_order The filter order for the discrete lowpass filter.
  def downsample_discrete! downsample_factor, filter_order
    @data = DiscreteResampling.downsample @data, @sample_rate, downsample_factor, filter_order
    @sample_rate /= downsample_factor
    return self
  end

  # Decrease the sample rate of signal data by the given factor using
  # discrete downsampling method. Return result in a new Signal object.
  # @param [Fixnum] downsample_factor Decrease the sample rate by this factor.
  # @param [Fixnum] filter_order The filter order for the discrete lowpass filter.
  def downsample_discrete downsample_factor, filter_order
    return self.clone.downsample_discrete!(downsample_factor, filter_order)
  end

  # Change the sample rate of signal data by the given up/down factors, using
  # discrete upsampling and downsampling methods. Modifies current object.
  # @param [Fixnum] upsample_factor Increase the sample rate by this factor.
  # @param [Fixnum] downsample_factor Decrease the sample rate by this factor.
  # @param [Fixnum] filter_order The filter order for the discrete lowpass filter.
  def resample_discrete! upsample_factor, downsample_factor, filter_order
    @data = DiscreteResampling.resample @data, @sample_rate, upsample_factor, downsample_factor, filter_order
    @sample_rate *= upsample_factor
    @sample_rate /= downsample_factor
    return self
  end

  # Change the sample rate of signal data by the given up/down factors, using
  # discrete upsampling and downsampling methods. Return result in a new Signal object.
  # @param [Fixnum] upsample_factor Increase the sample rate by this factor.
  # @param [Fixnum] downsample_factor Decrease the sample rate by this factor.
  # @param [Fixnum] filter_order The filter order for the discrete lowpass filter.
  def resample_discrete upsample_factor, downsample_factor, filter_order
    return self.clone.resample_discrete!(upsample_factor, downsample_factor, filter_order)
  end
  
  # Increase the sample rate of signal data by the given factor using
  # polynomial interpolation. Modifies current Signal object.
  # @param [Fixnum] upsample_factor Increase the sample rate by this factor.
  def upsample_polynomial! upsample_factor
    @data = PolynomialResampling.upsample @data, upsample_factor
    @sample_rate *= upsample_factor
    return self
  end

  # Increase the sample rate of signal data by the given factor using
  # polynomial interpolation. Returns result as a new Signal object.
  # @param [Fixnum] upsample_factor Increase the sample rate by this factor.
  def upsample_polynomial upsample_factor
    return self.clone.upsample_polynomial!(upsample_factor)
  end
  
  # Change the sample rate of signal data by the given up/down factors, using
  # polynomial upsampling and discrete downsampling. Modifies current Signal object.
  # @param [Fixnum] upsample_factor Increase the sample rate by this factor.
  # @param [Fixnum] downsample_factor Decrease the sample rate by this factor.
  # @param [Fixnum] filter_order The filter order for the discrete lowpass filter.
  def resample_hybrid! upsample_factor, downsample_factor, filter_order
    @data = HybridResampling.resample @data, @sample_rate, upsample_factor, downsample_factor, filter_order
    @sample_rate *= upsample_factor
    @sample_rate /= downsample_factor
    return self
  end

  # Change the sample rate of signal data by the given up/down factors, using
  # polynomial upsampling and discrete downsampling. Return result as a new Signal object.
  # @param [Fixnum] upsample_factor Increase the sample rate by this factor.
  # @param [Fixnum] downsample_factor Decrease the sample rate by this factor.
  # @param [Fixnum] filter_order The filter order for the discrete lowpass filter.
  def resample_hybrid upsample_factor, downsample_factor, filter_order
    return self.clone.resample_hybrid!(upsample_factor, downsample_factor, filter_order)
  end
  
  def frequency_domain fft_format = FrequencyDomain::FFT_MAGNITUDE_DECIBEL
    if @frequency_domain.nil?
      @frequency_domain = FrequencyDomain.new(
        :time_data => @data,
        :sample_rate => @sample_rate,
        :fft_format => fft_format
      )
    end
    return @frequency_domain
  end
  
  # Return the full output of forward FFT on the signal data.
  def fft_full
    frequency_domain.fft_full
  end

  # Return the first half of the the forward FFT on the signal data.
  def fft_half
    frequency_domain.fft_half
  end
  
  # Run FFT on signal data to find magnitude of frequency components.
  # @return [Hash] contains frequencies mapped to magnitudes.
  def freq_magnitudes
    freq_magnitudes = {}
    
    fft_half.each_index do |i|
      freq = frequency_domain.idx_to_freq(i)
      freq_magnitudes[freq] = fft_half[i]
    end
    
    return freq_magnitudes
  end

  # Apply FrequencyDomain.peaks to the signal and return the result.
  def freq_peaks
    return frequency_domain.peaks
  end
  
  # Apply FrequencyDomain.harmonic_series to the signal frequency peaks and
  # return the result.
  def harmonic_series opts = {}
    return frequency_domain.harmonic_series(opts)
  end
  
  # Return the lowest frequency of the signal harmonic series.
  def fundamental opts
    return harmonic_series(opts).min
  end
  
  # Calculate the energy in current signal data.
  def energy
    return @data.inject(0.0){|sum,x| sum + (x * x)}
  end
  
  # Calculate signal RMS (root-mean square), also known as quadratic mean, a
  # statistical measure of the magnitude.
  def rms
    Math.sqrt(energy / size)
  end
  
  # Apply Statistics.mean to the signal data.
  def mean
    Statistics.mean @data
  end
    
  # Apply Statistics.std_dev to the signal data.
  def std_dev
    Statistics.std_dev @data
  end
  
  # Apply Statistics.correlation to the signal data (as the image).
  def correlation feature, zero_padding = 0
    Statistics.correlation @data, feature, zero_padding
  end

  # Apply Features.extrema to the signal data.
  def extrema
    return Features.extrema(@data)
  end
  
  # Apply Features.outer_extrema to the signal data.
  def outer_extrema
    return Features.outer_extrema(@data)
  end
  
  # Apply Features.minima to the signal data.
  def minima
    return Features.minima(@data)
  end

  # Apply Features.negative_minima to the signal data.
  def negative_minima
    return Features.negative_minima(@data)
  end
  
  # Apply Features.maxima to the signal data.
  def maxima
    return Features.maxima(@data)
  end

  # Apply Features.positive_maxima to the signal data.
  def positive_maxima
    return Features.positive_maxima(@data)
  end
  
  # Operate on the signal data (in place) with the absolute value function.
  def abs!
    @data = @data.map {|x| x.abs }
    return self
  end
  
  # Operate on copy of the Signal object with the absolute value function.
  def abs
    self.clone.abs!
  end

  # reduce all samples to the given level  
  def normalize! level = 1.0
    self.divide!(@data.max / level)
  end
  
  # reduce all samples to the given level
  def normalize level = 1.0
    self.clone.normalize! level
  end
  
  # Apply Features.envelope to the signal data, and return either a new Signal
  # object or the raw envelope data.
  # @param [True/False] as_signal If true, return envelope data in a new signal
  #                               object. Otherwise, return raw envelope data.
  #                               Set to true by default.
  def envelope as_signal = true
    env_data = Features.envelope @data
    
    if as_signal
      return Signal.new(:sample_rate => @sample_rate, :data => env_data)
    else
      return env_data
    end
  end
  
  # Add data in array or other signal to the beginning of current data.
  def prepend! other
    if other.is_a?(Array)
      @data = other.concat @data
    elsif other.is_a?(Signal)
      @data = other.data.concat @data  
    end
    return self
  end

  # Add data in array or other signal to the beginning of current data.
  def prepend other
    clone.prepend! other
  end
  
  # Add data in array or other signal to the end of current data.
  def append! other
    if other.is_a?(Array)
      @data = @data.concat other
    elsif other.is_a?(Signal)
      @data = @data.concat other.data
    end
    return self
  end

  # Add data in array or other signal to the end of current data.
  def append other
    clone.append! other
  end
  
  # Add value, values in array, or values in other signal to the current
  # data values, and update the current data with the results.
  # @param other Can be Numeric (add same value to all data values), Array, or Signal.
  def add!(other)
    if other.is_a?(Numeric)
      @data.each_index do |i|
        @data[i] += other
      end
    elsif other.is_a?(Signal)
      raise ArgumentError, "other.data.size #{other.size} is not equal to data.size #{@data.size}" if other.data.size != @data.size
      @data.each_index do |i|
        @data[i] += other.data[i]
      end
    elsif other.is_a?(Array)
      raise ArgumentError, "other.size #{other.size} is not equal to data.size #{@data.size}" if other.size != @data.size
      @data.each_index do |i|
        @data[i] += other[i]
      end
    else
      raise ArgumentError, "other is not a Numeric, Signal, or Array"
    end
    return self
  end

  # Add value, values in array, or values in other signal to the current
  # data values, and return a new Signal object with the results.
  # @param other Can be Numeric (add same value to all data values), Array, or Signal.
  def add(other)
    clone.add! other
  end
  
  # Subtract value, values in array, or values in other signal from the current
  # data values, and update the current data with the results.
  # @param other Can be Numeric (subtract same value from all data values), Array, or Signal.
  def subtract!(other)
    if other.is_a?(Numeric)
      @data.each_index do |i|
        @data[i] -= other
      end
    elsif other.is_a?(Signal)
      raise ArgumentError, "other.data.size #{other.size} is not equal to data.size #{@data.size}" if other.data.size != @data.size
      @data.each_index do |i|
        @data[i] -= other.data[i]
      end
    elsif other.is_a?(Array)
      raise ArgumentError, "other.size #{other.size} is not equal to data.size #{@data.size}" if other.size != @data.size
      @data.each_index do |i|
        @data[i] -= other[i]
      end
    else
      raise ArgumentError, "other is not a Numeric, Signal, or Array"
    end
    return self
  end

  # Subtract value, values in array, or values in other signal from the current
  # data values, and return a new Signal object with the results.
  # @param other Can be Numeric (subtract same value from all data values), Array, or Signal.
  def subtract(other)
    clone.subtract! other
  end
  
  # Multiply value, values in array, or values in other signal with the current
  # data values, and update the current data with the results.
  # @param other Can be Numeric (multiply all data values by the same value),
  #              Array, or Signal.  
  def multiply!(other)
    if other.is_a?(Numeric)
      @data.each_index do |i|
        @data[i] *= other
      end
    elsif other.is_a?(Signal)
      raise ArgumentError, "other.data.size #{other.size} is not equal to data.size #{@data.size}" if other.data.size != @data.size
      @data.each_index do |i|
        @data[i] *= other.data[i]
      end
    elsif other.is_a?(Array)
      raise ArgumentError, "other.size #{other.size} is not equal to data.size #{@data.size}" if other.size != @data.size
      @data.each_index do |i|
        @data[i] *= other[i]
      end
    else
      raise ArgumentError, "other is not a Numeric, Signal, or Array"
    end
    return self
  end
  
  # Multiply value, values in array, or values in other signal with the current
  # data values, and return a new Signal object with the results.
  # @param other Can be Numeric (multiply all data values by the same value),
  #              Array, or Signal.  
  def multiply(other)
    clone.multiply! other
  end
  
  # Divide value, values in array, or values in other signal into the current
  # data values, and update the current data with the results.
  # @param other Can be Numeric (divide same all data values by the same value),
  #              Array, or Signal.
  def divide!(other)
    if other.is_a?(Numeric)
      @data.each_index do |i|
        @data[i] /= other
      end
    elsif other.is_a?(Signal)
      raise ArgumentError, "other.data.size #{other.size} is not equal to data.size #{@data.size}" if other.data.size != @data.size
      @data.each_index do |i|
        @data[i] /= other.data[i]
      end
    elsif other.is_a?(Array)
      raise ArgumentError, "other.size #{other.size} is not equal to data.size #{@data.size}" if other.size != @data.size
      @data.each_index do |i|
        @data[i] /= other[i]
      end
    else
      raise ArgumentError, "other is not a Numeric, Signal, or Array"
    end
    return self
  end

  # Divide value, values in array, or values in other signal into the current
  # data values, and return a new Signal object with the results.
  # @param other Can be Numeric (divide same all data values by the same value),
  #              Array, or Signal.
  def divide(other)
    clone.divide! other
  end

  alias_method :+, :add
  alias_method :-, :subtract
  alias_method :*, :multiply
  alias_method :/, :divide
    
  # Applies Calculus.derivative on the signal data, and returns a new Signal
  # object with the result.
  def derivative
    return Signal.new(:sample_rate => @sample_rate, :data => Calculus.derivative(@data))
  end

  # Applies Calculus.integral on the signal data, and returns a new Signal
  # object with the result.
  def integral
    return Signal.new(:sample_rate => @sample_rate, :data => Calculus.integral(@data))
  end
  
  # Removes all but the given range of frequencies from the signal, using
  # frequency domain filtering. Modifes and returns the current object.
  def remove_frequencies! freq_range
    modify_freq_content freq_range, :remove
  end
  
  # Removes the given range of frequencies from the signal, using
  # frequency domain filtering. Modifes a clone of the current object,
  # returning the clone.
  def remove_frequencies freq_range
    return self.clone.remove_frequencies!(freq_range)
  end
  
  # Removes all but the given range of frequencies from the signal, using
  # frequency domain filtering. Modifes and returns the current object.
  def keep_frequencies! freq_range
    modify_freq_content freq_range, :keep
  end

  # Removes all but the given range of frequencies from the signal, using
  # frequency domain filtering. Modifes a clone of the current object,
  # returning the clone.
  def keep_frequencies freq_range
    return self.clone.keep_frequencies!(freq_range)
  end
  
  private
  
  def modify_freq_content freq_range, mod_type
    nyquist = @sample_rate / 2
    
    unless freq_range.min.between?(0, nyquist)
      raise ArgumentError, "freq_range.min #{freq_range.min} is not between 0 and #{nyquist}"
    end

    unless freq_range.max.between?(0, nyquist)
      raise ArgumentError, "freq_range.min #{freq_range.min} is not between 0 and #{nyquist}"
    end
    
    power_of_two = FFT.power_of_two?(size)
    if power_of_two
      freq_domain = FFT.forward @data
    else
      freq_domain = DFT.forward @data
    end
    
    # cutoff indices for real half
    a = ((freq_range.min * size) / @sample_rate).round
    b = ((freq_range.max * size) / @sample_rate).round
    
    window_size = b - a + 1
    window_data = RectangularWindow.new(window_size).data
        
    case mod_type
    when :keep
      new_freq_data = Array.new(size, Complex(0))
      
      window_size.times do |n|
        i = n + a
        new_freq_data[i] = freq_domain[i] * window_data[n]
      end

      window_size.times do |n|
        i = n + (size - 1 - b)
        new_freq_data[i] = freq_domain[i] * window_data[n]
      end
    when :remove
      new_freq_data = freq_domain.clone
      
      window_size.times do |n|
        i = n + a
        new_freq_data[i] = freq_domain[i] * (Complex(1.0) - window_data[n])
      end

      window_size.times do |n|
        i = n + (size - 1 - b)
        new_freq_data[i] = freq_domain[i] * (Complex(1.0) - window_data[n])
      end
    else
      raise ArgumentError, "unkown mod_type #{mod_type}"
    end
    
    if power_of_two
      data = FFT.inverse new_freq_data
    else
      data = DFT.inverse new_freq_data
    end
    
    @data = data.map {|complex| complex.real }
    return self
  end
end
end
