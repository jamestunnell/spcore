module SPCore
# A generic oscillator base class, which can render a sample for any phase 
# between -PI and +PI.
#
# @author James Tunnell
class Oscillator
  include Hashmake::HashMakeable
  attr_accessor :wave_type, :amplitude, :dc_offset
  attr_reader :frequency, :sample_rate, :phase_offset
  
  # Defines a sine wave type.
  WAVE_SINE = :waveSine
  # Defines a triangle wave type.
  WAVE_TRIANGLE = :waveTriangle
  # Defines a sawtooth wave type.
  WAVE_SAWTOOTH = :waveSawtooth
  # Defines a square wave type.
  WAVE_SQUARE = :waveSquare

  # Defines a list of the valid wave types.
  WAVES = [WAVE_SINE, WAVE_TRIANGLE, WAVE_SAWTOOTH, WAVE_SQUARE]
  
  # Used to process hashed arguments in #initialize.
  ARG_SPECS = [
    Hashmake::ArgSpec.new(:reqd => true, :key => :sample_rate, :type => Float, :validator => ->(a){ a > 0.0 } ),
    Hashmake::ArgSpec.new(:reqd => false, :key => :wave_type, :type => Symbol, :default => WAVE_SINE, :validator => ->(a){ WAVES.include? a } ),
    Hashmake::ArgSpec.new(:reqd => false, :key => :frequency, :type => Float, :default => 1.0, :validator => ->(a){ a > 0.0 } ),
    Hashmake::ArgSpec.new(:reqd => false, :key => :amplitude, :type => Float, :default => 1.0 ),
    Hashmake::ArgSpec.new(:reqd => false, :key => :phase_offset, :type => Float, :default => 0.0 ),
    Hashmake::ArgSpec.new(:reqd => false, :key => :dc_offset, :type => Float, :default => 0.0 ),
  ]
  
  # A new instance of Oscillator. The controllable wave parameters are frequency,
  # amplitude, phase offset, and DC offset. The current phase angle is initialized
  # to the given phase offset.
  #
  # @param [Hash] args Hashed arguments. Required key is :sample_rate. Optional keys are
  #                    :wave_type, :frequency, :amplitude, :phase_offset, and :dc_offset.
  #                    See ARG_SPECS for more details.  
  def initialize args
    hash_make Oscillator::ARG_SPECS, args
    
    @phase_angle_incr = (@frequency * TWO_PI) / @sample_rate
    @current_phase_angle = @phase_offset
  end
  
  # Set the sample rate (also updates the rate at which phase angle increments).
  # @raise [ArgumentError] if sample rate is not positive.
  def sample_rate= sample_rate
    raise ArgumentError, "sample_rate is not > 0" unless sample_rate > 0
    @sample_rate = sample_rate
    self.frequency = @frequency
  end
  
  # Set the frequency (also updates the rate at which phase angle increments).
  def frequency= frequency
    raise ArgumentError, "frequency is not > 0" unless frequency > 0
    @frequency = frequency
    @phase_angle_incr = (@frequency * TWO_PI) / @sample_rate
  end
  
  # Set the phase angle offset. Update the current phase angle according to the
  # difference between the current phase offset and the new phase offset.
  def phase_offset= phase_offset
    @current_phase_angle += (phase_offset - @phase_offset);
    @phase_offset = phase_offset
  end

  # Step forward one sampling period and sample the oscillator waveform.
  def sample
    output = 0.0

    while(@current_phase_angle < -Math::PI)
      @current_phase_angle += TWO_PI
    end

    while(@current_phase_angle > Math::PI)
      @current_phase_angle -= TWO_PI
    end

    case @wave_type
    when WAVE_SINE
      output = @amplitude * sine(@current_phase_angle) + @dc_offset
    when WAVE_TRIANGLE
      output = @amplitude * triangle(@current_phase_angle) + @dc_offset
    when WAVE_SQUARE
      output = @amplitude * square(@current_phase_angle) + @dc_offset
    when WAVE_SAWTOOTH
      output = @amplitude * sawtooth(@current_phase_angle) + @dc_offset
    else
      raise "Encountered unexpected wave type #{@wave_type}"
    end
    
    @current_phase_angle += @phase_angle_incr
    return output
  end
  
  # constant used to calculate sine wave
  K_SINE_B = 4.0 / Math::PI
  # constant used to calculate sine wave
  K_SINE_C = -4.0 / (Math::PI * Math::PI)
  # Q = 0.775
  # constant used to calculate sine wave
  K_SINE_P = 0.225
  
  # generate a sine wave:
  # input range: -PI to PI
  # ouput range: -1 to 1
  def sine x
    y = K_SINE_B * x + K_SINE_C * x * x.abs
    # for extra precision
    y = K_SINE_P * (y * y.abs - y) + y   # Q * y + P * y * y.abs
    
    # sin normally output outputs -1 to 1, so to adjust
    # it to output 0 to 1, return (y*0.5)+0.5
    return y
  end

  # constant used to calculate triangle wave
  K_TRIANGLE_A = 2.0 / Math::PI;

  # generate a triangle wave:
  # input range: -PI to PI
  # ouput range: -1 to 1
  def triangle x
    (K_TRIANGLE_A * x).abs - 1.0
  end

  # generate a square wave (50% duty cycle):
  # input range: -PI to PI
  # ouput range: 0 to 1
  def square x
    (x >= 0.0) ? 1.0 : -1.0
  end

  # constant used to calculate sawtooth wave
  K_SAWTOOTH_A = 1.0 / Math::PI

  # generate a sawtooth wave:
  # input range: -PI to PI
  # ouput range: -1 to 1
  def sawtooth x
    K_SAWTOOTH_A * x
  end

end
end
