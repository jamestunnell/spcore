module SPCore
# Store signal data and provide some useful methods for working with
# (testing and analyzing) the data.
#
# @author James Tunnell
class Signal
  include Hashmake::HashMakeable
  
  # Used to process hashed arguments in #initialize.
  ARG_SPECS = [
    Hashmake::ArgSpec.new(:key => :data, :reqd => true, :type => Array, :validator => ->(a){ a.any? }),
    Hashmake::ArgSpec.new(:key => :sample_rate, :reqd => true, :type => Float, :validator => ->(a){ a > 0.0 })
  ]
  
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
  def plot_data plot_against_fraction
    xtitle = (plot_against_fraction ? "fraction of total samples" : "sample numbers")
    plotter = Plotter.new(:title => "signal data sequence", :xtitle => xtitle, :ytitle => "sample values")
    titled_sequence = {"signal data" => @data}
    plotter.plot_1d titled_sequence, plot_against_fraction
  end
  
  # Increase the sample rate of signal data by the given factor using
  # discrete upsampling method.
  # @param [Fixnum] upsample_factor Increase the sample rate by this factor.
  # @param [Fixnum] filter_order The filter order for the discrete lowpass filter.
  def upsample_discrete upsample_factor, filter_order
    @data = DiscreteResampling.upsample @data, @sample_rate, upsample_factor, filter_order
    @sample_rate *= upsample_factor
    return self
  end

  # Decrease the sample rate of signal data by the given factor using
  # discrete downsampling method.
  # @param [Fixnum] downsample_factor Decrease the sample rate by this factor.
  # @param [Fixnum] filter_order The filter order for the discrete lowpass filter.
  def downsample_discrete downsample_factor, filter_order
    @data = DiscreteResampling.downsample @data, @sample_rate, downsample_factor, filter_order
    @sample_rate /= downsample_factor
    return self
  end

  # Change the sample rate of signal data by the given up/down factors, using
  # discrete upsampling and downsampling methods.
  # @param [Fixnum] upsample_factor Increase the sample rate by this factor.
  # @param [Fixnum] downsample_factor Decrease the sample rate by this factor.
  # @param [Fixnum] filter_order The filter order for the discrete lowpass filter.
  def resample_discrete upsample_factor, downsample_factor, filter_order
    @data = DiscreteResampling.resample @data, @sample_rate, upsample_factor, downsample_factor, filter_order
    @sample_rate *= upsample_factor
    @sample_rate /= downsample_factor
    return self
  end
  
  # Increase the sample rate of signal data by the given factor using
  # polynomial interpolation.
  # @param [Fixnum] upsample_factor Increase the sample rate by this factor.
  def upsample_polynomial upsample_factor
    @data = PolynomialResampling.upsample @data, @sample_rate, upsample_factor
    @sample_rate *= upsample_factor
    return self
  end

  # Change the sample rate of signal data by the given up/down factors, using
  # polynomial upsampling and discrete downsampling.
  # @param [Fixnum] upsample_factor Increase the sample rate by this factor.
  # @param [Fixnum] downsample_factor Decrease the sample rate by this factor.
  # @param [Fixnum] filter_order The filter order for the discrete lowpass filter.
  def resample_hybrid upsample_factor, downsample_factor, filter_order
    @data = HybridResampling.resample @data, @sample_rate, upsample_factor, downsample_factor, filter_order
    @sample_rate *= upsample_factor
    @sample_rate /= downsample_factor
    return self
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
  
  # Return a 
  def envelope attack_time, release_time
    raise ArgumentError, "attack_time #{attack_time } is less than or equal to zero" if attack_time <= 0.0
    raise ArgumentError, "release_time #{release_time} is less than or equal to zero" if release_time <= 0.0
    
    env_detector = EnvelopeDetector.new(:attack_time => attack_time, :release_time => release_time, :sample_rate => @sample_rate)
    
    envelope = Array.new(@data.count)
    
    for i in 0...@data.count do
      envelope[i] = env_detector.process_sample @data[i]
    end
    
    return envelope
  end
  
  # Add data in array or other signal to the beginning of current data.
  def prepend other
    if other.is_a?(Array)
      @data = other.concat @data
    elsif other.is_a?(Signal)
      @data = other.data.concat @data  
    end
    return self
  end

  # Add data in array or other signal to the end of current data.
  def append other
    if other.is_a?(Array)
      @data = @data.concat other
    elsif other.is_a?(Signal)
      @data = @data.concat other.data
    end
    return self
  end
  
  # Add value, values in array, or values in other signal to the current
  # data values, and update the current data with the results.
  # @param other Can be Numeric (add same value to all data values), Array, or Signal.
  def +(other)
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
  
  # Subtract value, values in array, or values in other signal from the current
  # data values, and update the current data with the results.
  # @param other Can be Numeric (subtract same value from all data values), Array, or Signal.
  def -(other)
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

  # Multiply value, values in array, or values in other signal with the current
  # data values, and update the current data with the results.
  # @param other Can be Numeric (multiply all data values by the same value),
  #              Array, or Signal.  
  def *(other)
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
  
  # Divide value, values in array, or values in other signal into the current
  # data values, and update the current data with the results.
  # @param other Can be Numeric (divide same all data values by the same value),
  #              Array, or Signal.
  def /(other)
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

  alias_method :add, :+
  alias_method :subtract, :-
  alias_method :multiply, :*
  alias_method :divide, :/
  
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
end

end