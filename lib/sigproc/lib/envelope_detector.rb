module SigProc
class EnvelopeDetector
  include Hashmake::HashMakeable
  
  ARG_SPECS = [
    Hashmake::ArgSpec.new(:reqd => true, :key => :sample_rate, :type => Float, :validator => ->(a){ a > 0.0 } ),
    Hashmake::ArgSpec.new(:reqd => true, :key => :attack_time, :type => Float, :validator => ->(a){ a > 0.0 } ),
    Hashmake::ArgSpec.new(:reqd => true, :key => :release_time, :type => Float, :validator => ->(a){ a > 0.0 } ),
  ]

  attr_reader :envelope, :sample_rate, :attack_time, :release_time
  
  def initialize args
    hash_make EnvelopeDetector::ARG_SPECS, args

    @g_attack = Math.exp(-1.0 / (sample_rate * attack_time))
    @g_release = Math.exp(-1.0 / (sample_rate * release_time))
    
    @envelope = 0.0
  end
  
  def process_sample sample
    input_abs = sample.abs
      
    if @envelope < input_abs
      @envelope = (@envelope * @g_attack) + ((1.0 - @g_attack) * input_abs)
    else
      @envelope = (@envelope * @g_release) + ((1.0 - @g_release) * input_abs)
    end
    
    return @envelope
  end

end
end
