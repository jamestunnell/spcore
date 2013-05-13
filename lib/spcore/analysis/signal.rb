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
    :sample_rate => arg_spec(:reqd => true, :type => Fixnum, :validator => ->(a){ a > 0.0 })
  }
  
  attr_reader :data, :sample_rate

  # A new instance of Signal.
  #
  # @param [Hash] hashed_args Hashed arguments. Required keys are :data and
  #                           :sample_rate. See ARG_SPECS for more details.
  def initialize hashed_args
    hash_make Signal::ARG_SPECS, hashed_args
  end
  
  # Produce a new Signal object with the same data.
  def clone
    Signal.new(:data => @data.clone, :sample_rate => @sample_rate)
  end
  
  # Produce a new Signal object with a subset of the current signal data.
  # @param [Range] range Used to pick the data range.
  def subset range
    Signal.new(:data => @data[range], :sample_rate => @sample_rate)
  end
  
  # Size of the signal data.
  def size
    @data.size
  end
  
  # Access signal data.
  def [](arg)
    @data[arg]
  end
  
  # Plot the signal data, either against sample numbers or fraction of total samples.
  # @param plot_against_fraction If false, plot data against sample number. If true,
  #                              plot against fraction of total samples.
  def plot_data plot_against_fraction = false
    xtitle = (plot_against_fraction ? "fraction of total samples" : "sample numbers")
    plotter = Plotter.new(:title => "signal data sequence", :xtitle => xtitle, :ytitle => "sample values")
    titled_sequence = {"signal data" => @data}
    plotter.plot_1d titled_sequence, plot_against_fraction
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
  
  # Run FFT on signal data to find magnitude of frequency components.
  # @param convert_to_db If true, magnitudes are converted to dB values.
  # @return [Hash] contains frequencies mapped to magnitudes.
  def freq_magnitudes convert_to_db = false
    fft_output = FFT.forward @data
    
    fft_output = fft_output[0...(fft_output.size / 2)]  # ignore second half
    fft_output = fft_output.map {|x| x.magnitude }  # map complex value to magnitude
    
    if convert_to_db
      fft_output = fft_output.map {|x| Gain.linear_to_db x}
    end
    
    freq_magnitudes = {}
    fft_output.each_index do |i|
      size = fft_output.size * 2 # mul by 2 because the second half of original fft_output was removed
      freq = (@sample_rate * i) / size
      freq_magnitudes[freq] = fft_output[i]
    end
    
    return freq_magnitudes
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
  
  # Compute the mean of signal data.
  def mean
    sum = @data.inject(0){ |s, x| s + x }
    return sum.to_f / size
  end
  
  # Find extrema (maxima, minima) within signal data.
  def extrema
    return Extrema.new(@data)
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
  
  def normalize! level = 1.0
    self.divide!(@data.max / level)
  end
  
  # reduce all samples to 
  def normalize level = 1.0
    self.clone.normalize! level
  end
  
  # Determine the envelope of the current Signal and return either a Envelope
  # or a new Signal object as a result.
  # @param [True/False] make_signal If true, return envelope data in a new
  #                     Otherwise, return an Envelope object.
  def envelope
    Signal.new(:sample_rate => @sample_rate, :data => Envelope.new(@data).data)
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
  
  # Determine how well the another signal (g) correlates to the current signal (f).
  # Correlation is determined at every point in f. The signal g must not be
  # longer than f. Correlation involves moving g along f and performing
  # convolution. Starting a the beginning of f, it continues until the end
  # of g hits the end of f. Doesn't actually convolve, though. Instead, it
  # adds 
  #
  # @param [Array] other_signal The signal to look for in the current signal.
  # @param [true/false] normalize Flag to indicate if normalization should be
  #                               performed on input signals (performed on a copy
  #                               of the original data).
  # @raise [ArgumentError] if other_signal is not a Signal or Array.
  # @raise [ArgumentError] if other_signal is longer than the current signal data.
  def cross_correlation other_signal, normalize = true
    if other_signal.is_a? Signal
      other_data = other_signal.data
    elsif other_signal.is_a? Array
      other_data = other_signal
    else
      raise ArgumentError, "other_signal is not a Signal or Array"
    end
    
    f = @data
    g = other_data
    
    raise ArgumentError, "g.count #{g.count} is greater than f.count #{f.count}" if g.count > f.count
    
    g_size = g.count
    f_size = f.count
    f_g_diff = f_size - g_size
    
    cross_correlation = []

    if normalize
      max = (f.max_by {|x| x.abs }).abs.to_f
      
      f = f.clone
      g = g.clone
      f.each_index {|i| f[i] =  f[i] / max }
      g.each_index {|i| g[i] =  g[i] / max }
    end

    #puts "f: #{f.inspect}"
    #puts "g: #{g.inspect}"

    for n in 0..f_g_diff do
      f_window = (n...(n + g_size)).entries
      g_window = (0...g_size).entries
      
      sample = 0.0
      for i in 0...f_window.count do
        i_f = f_window[i]
        i_g = g_window[i]
        
        #if use_relative_error
        target = g[i_g].to_f
        actual = f[i_f]
        
        #if target == 0.0 && actual != 0.0 && normalize
        #  puts "target is #{target} and actual is #{actual}"
        #  error = 1.0
        #else
          error = (target - actual).abs# / target
        #end
        
        sample += error
        
        #else
        #  sample += (f[i_f] * g[i_g])
        #end
      end
      
      cross_correlation << (sample)# / g_size.to_f)
    end
    
    return cross_correlation
  end
  
  # Differentiates the signal data.
  # @param [true/false] make_signal If true, return the result as a new
  #                                 Signal object. Otherwise, return result
  #                                 as an array.
  def derivative
    raise "Signal does not have at least 2 samples" unless @data.size > 2
    
    derivative = Array.new(@data.size)
    sample_period = 1.0 / @sample_rate
    
    for i in 1...@data.count
      derivative[i] = (@data[i] - @data[i-1]) / sample_period
    end
    
    derivative[0] = derivative[1]
    
    return Signal.new(:sample_rate => @sample_rate, :data => derivative)
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