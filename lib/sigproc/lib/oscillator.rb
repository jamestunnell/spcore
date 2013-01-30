module SigProc
class Oscillator
  include HashMake
  attr_accessor :wave_type, :amplitude, :dc_bias
  attr_reader :frequency, :sample_rate, :phase_angle
  
  WAVE_SINE = :waveSine
  WAVE_TRIANGLE = :waveTriangle
  WAVE_SAWTOOTH = :waveSawtooth
  WAVE_SQUARE = :waveSquare

  WAVES = [WAVE_SINE, WAVE_TRIANGLE, WAVE_SAWTOOTH, WAVE_SQUARE]
  
  HASHED_ARGS = [
    HashedArg.new(:reqd => true, :key => :sample_rate, :type => Float, :validator => ->(a){ a > 0.0 } ),
    HashedArg.new(:reqd => false, :key => :wave_type, :type => Symbol, :default => WAVE_SINE, :validator => ->(a){ WAVES.include? a } ),
    HashedArg.new(:reqd => false, :key => :frequency, :type => Float, :default => 1.0, :validator => ->(a){ a > 0.0 } ),
    HashedArg.new(:reqd => false, :key => :amplitude, :type => Float, :default => 1.0 ),
    HashedArg.new(:reqd => false, :key => :phase_angle, :type => Float, :default => 0.0 ),
    HashedArg.new(:reqd => false, :key => :dc_bias, :type => Float, :default => 0.0 ),
  ]

  def initialize args
    hash_make args
    
    @phase_angle_incr = (@frequency * TWO_PI) / @sample_rate
    @current_phase_angle = @phase_angle
  end
  
  def sample_rate= sample_rate
    @sample_rate = sample_rate
    self.frequency = @frequency
  end
  
  def frequency= frequency
    @frequency = frequency
    @phase_angle_incr = (@frequency * TWO_PI) / @sample_rate
  end
  
  def phase_angle= phase_angle
    @current_phase_angle += (phase_angle - @phase_angle);
    @phase_angle = phase_angle
  end

  def sample
    output = 0.0

    while(@current_phase_angle < NEG_PI)
      @current_phase_angle += TWO_PI
    end

    while(@current_phase_angle > Math::PI)
      @current_phase_angle -= TWO_PI
    end

    case @wave_type
    when WAVE_SINE
      output = @amplitude * sine(@current_phase_angle) + @dc_bias
    when WAVE_TRIANGLE
      output = @amplitude * triangle(@current_phase_angle) + @dc_bias
    when WAVE_SQUARE
      output = @amplitude * square(@current_phase_angle) + @dc_bias
    when WAVE_SAWTOOTH
      output = @amplitude * sawtooth(@current_phase_angle) + @dc_bias
    else
      raise "Encountered unexpected wave type #{@wave_type}"
    end
    
    @current_phase_angle += @phase_angle_incr
    return output
  end

  K_SINE_B = 4.0 / Math::PI
  K_SINE_C = -4.0 / (Math::PI * Math::PI)
  # Q = 0.775
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

  K_SAWTOOTH_A = 1.0 / Math::PI

  # generate a sawtooth wave:
  # input range: -PI to PI
  # ouput range: -1 to 1
  def sawtooth x
    K_SAWTOOTH_A * x
  end

end
end
