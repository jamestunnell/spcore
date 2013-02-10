module SPCore
class SignalGenerator
  include Hashmake::HashMakeable
  
  ARG_SPECS = [
    Hashmake::ArgSpec.new(:key => :size, :reqd => true, :type => Fixnum, :validator => ->(a){ a > 0 }),
    Hashmake::ArgSpec.new(:key => :sample_rate, :reqd => true, :type => Float, :validator => ->(a){ a > 0.0 })
  ]
  
  attr_reader :sample_rate, :size
  
  def initialize args
    hash_make ARG_SPECS, args
  end
  
  def make_signal freqs, extra_osc_args = {}
    args = { :sample_rate => @sample_rate }.merge! extra_osc_args
    oscs = []
    freqs.each do |freq|
      oscs.push Oscillator.new args.merge(:frequency => freq)
    end
    
    output = Array.new(size, 0.0)
    size.times do |n|
      oscs.each do |osc|
        output[n] += osc.sample
      end
    end
    
    return output
  end
end
end
