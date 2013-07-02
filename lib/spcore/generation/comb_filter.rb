module SPCore
class CombFilter
  include Hashmake::HashMakeable
  
  FEED_FORWARD = :feedForward
  FEED_BACK = :feedBack
  
  TYPES = [ FEED_FORWARD, FEED_BACK ]
  
  ARG_SPECS = {
    :type => arg_spec(:reqd => true, :type => Symbol, :validator => ->(a){ TYPES.include?(a)}),
    :frequency => arg_spec(:reqd => true, :type => Numeric, :validator => ->(a){ a > 0}),
    :alpha => arg_spec(:reqd => true, :type => Float, :validator => ->(a){ a.between?(0.0,1.0) })
  }
  
  attr_reader :type, :frequency, :alpha
  
  def initialize args
    hash_make CombFilter::ARG_SPECS, args
    calculate_params
  end
  
  def type= type
    validate_arg ARG_SPECS[:type], type
    @type = type
  end

  def frequency= frequency
    validate_arg ARG_SPECS[:frequency], frequency
    @frequency = frequency
    calculate_params
  end
  
  def alpha= alpha
    validate_arg ARG_SPECS[:alpha], alpha
    @alpha = alpha
  end
  
  def frequency_response_at x
    output = 0
    if @type == FEED_FORWARD
      output = Math.sqrt((1.0 + @alpha**2) + 2.0 * @alpha * Math.cos(@k * x))
    elsif @type == FEED_BACK
      output = 1.0 / Math.sqrt((1.0 + alpha**2) - 2.0 * @alpha * Math.cos(@k * x))
    end
    return output
  end
  
  def frequency_response sample_rate, sample_count
    output = []
    sample_period = 1.0 / sample_rate
    sample_count.times do |n|
      x = sample_period * n
      output.push frequency_response_at(x)
    end
    return output
  end
  
  private
  
  def calculate_params
    @k = (Math::PI * 2) * @frequency
  end
end
end