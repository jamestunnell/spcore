module SPCore
# Provides methods for generating a Signal that contains test waveforms or noise.
class SignalGenerator
  include Hashmake::HashMakeable
  
  # used to process hashed args in #initialize.
  ARG_SPECS = {
    :size => arg_spec(:reqd => true, :type => Fixnum, :validator => ->(a){ a > 0 }),
    :sample_rate => arg_spec(:reqd => true, :type => Fixnum, :validator => ->(a){ a > 0 })
  }
  
  attr_reader :sample_rate, :size
  
  # A new instance of SignalGenerator.
  # @param [Hash] args Required keys are :sample_rate and :size.
  def initialize args
    hash_make args, ARG_SPECS
  end
  
  # Generate a Signal object with noise data.
  def make_noise amplitude = 1.0
    output = Array.new(@size)
    output.each_index do |i|
      output[i] = rand * amplitude
    end
    
    return Signal.new(:sample_rate => @sample_rate, :data => output)
  end
  
  # Generate a Signal object with waveform data at the given frequencies.
  def make_signal freqs, extra_osc_args = {}
    args = { :sample_rate => @sample_rate }.merge! extra_osc_args
    oscs = []
    freqs.each do |freq|
      oscs.push Oscillator.new args.merge(:frequency => freq)
    end
    
    output = Array.new(@size, 0.0)
    @size.times do |n|
      oscs.each do |osc|
        output[n] += osc.sample
      end
    end
    
    return Signal.new(:sample_rate => @sample_rate, :data => output)
  end
end
end
