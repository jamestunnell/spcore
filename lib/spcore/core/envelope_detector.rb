module SPCore
# Tracks the envelope of samples as they are passed in one by one.
#
# @author James Tunnell
class EnvelopeDetector
  include Hashmake::HashMakeable
  
  # Used to process hashed arguments in #initialize.
  ARG_SPECS = [
    Hashmake::ArgSpec.new(:reqd => true, :key => :sample_rate, :type => Float, :validator => ->(a){ a > 0.0 } ),
    Hashmake::ArgSpec.new(:reqd => true, :key => :attack_time, :type => Float, :validator => ->(a){ a > 0.0 } ),
    Hashmake::ArgSpec.new(:reqd => true, :key => :release_time, :type => Float, :validator => ->(a){ a > 0.0 } ),
  ]

  attr_reader :envelope, :sample_rate, :attack_time, :release_time

  # A new instance of EnvelopeDetector. The envelope is initialized to zero.
  #
  # @param [Hash] args Hashed arguments. Valid keys are :sample_rate (reqd),
  #                    :attack_time (in seconds) (reqd) and :release_time
  #                    (in seconds) (reqd). See ARG_SPECS for more details.  
  def initialize args
    hash_make EnvelopeDetector::ARG_SPECS, args

    @g_attack = Math.exp(-1.0 / (sample_rate * attack_time))
    @g_release = Math.exp(-1.0 / (sample_rate * release_time))
    
    @envelope = 0.0
  end
  
  # Set the attack time (in seconds).
  def attack_time= attack_time
    raise ArgumentError, "attack_time is <= 0.0" if attack_time <= 0.0
    @g_attack = Math.exp(-1.0 / (sample_rate * attack_time))
    @attack_time = attack_time
  end

  # Set the release time (in seconds).
  def release_time= release_time
    raise ArgumentError, "release_time is <= 0.0" if release_time <= 0.0
    @g_release = Math.exp(-1.0 / (sample_rate * release_time))
    @release_time = release_time
  end
  
  # Process a sample, returning the updated envelope.
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
