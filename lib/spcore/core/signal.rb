module SPCore

class Signal
  include Hashmake::HashMakeable
  
  ARG_SPECS = [
    Hashmake::ArgSpec.new(:key => :data, :reqd => true, :type => Array, :validator => ->(a){ a.any? }),
    Hashmake::ArgSpec.new(:key => :sample_rate, :reqd => true, :type => Float, :validator => ->(a){ a > 0.0 })
  ]
  
  attr_reader :data, :sample_rate
  
  def initialize hashed_args
    hash_make Signal::ARG_SPECS, hashed_args
  end
  
  def clone
    Signal.new(:data => @data.clone, :sample_rate => @sample_rate)
  end
  
  def subset range
    Signal.new(:data => @data[range], :sample_rate => @sample_rate)
  end
  
  def size
    @data.size
  end
  
  def [](arg)
    @data[arg]
  end
  
  def upsample_discrete upsample_factor, filter_order
    @data = DiscreteResampling.upsample @data, @sample_rate, upsample_factor, filter_order
    @sample_rate *= upsample_factor
    return self
  end

  def upsample_polynomial upsample_factor
    @data = PolynomialResampling.upsample @data, @sample_rate, upsample_factor
    @sample_rate *= upsample_factor
    return self
  end

  def freq_magnitudes convert_to_db = false
    skip_second_half = true
    dft_output = DFT.forward_dft @data, skip_second_half
    
    # map complex value to magnitude
    dft_output = dft_output.map {|x| x.magnitude }
    
    if convert_to_db
      dft_output = dft_output.map {|x| Gain.linear_to_db x}
    end
    
    freq_magnitudes = {}
    dft_output.each_index do |i|
      size = dft_output.size
      if skip_second_half
        size *= 2
      end
      freq = (@sample_rate * i) / size
      freq_magnitudes[freq] = dft_output[i]
    end
    
    return freq_magnitudes
  end

  def energy
    return @data.inject(0.0){|sum,x| sum + (x * x)}
  end
  
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
  
  def prepend other
    if other.is_a?(Array)
      @data = other.concat @data
    elsif other.is_a?(Signal)
      @data = other.data.concat @data  
    end
    return self
  end

  def append other
    if other.is_a?(Array)
      @data = @data.concat other
    elsif other.is_a?(Signal)
      @data = @data.concat other.data
    end
    return self
  end
  
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