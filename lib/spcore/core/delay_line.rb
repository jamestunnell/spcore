module SPCore
# Delays samples for a period of time by pushing them through a circular buffer.
#
# @author James Tunnell
class DelayLine
  include Hashmake::HashMakeable
  
  attr_reader :sample_rate, :max_delay_seconds, :delay_seconds, :delay_samples

  # Used to process hashed arguments in #initialize.
  ARG_SPECS = {
    :sample_rate => arg_spec(:reqd => true, :type => Float, :validator => ->(a){ a > 0.0 } ),
    :max_delay_seconds => arg_spec(:reqd => true, :type => Float, :validator => ->(a){ (a > 0.0) } ),
    :delay_seconds => arg_spec(:reqd => false, :type => Float, :default => 0.0, :validator => ->(a){ a >= 0.0 } ),
  }
  
  # A new instance of DelayLine. The circular buffer is filled by pushing an array
  # of zeros.
  # @param [Hash] args Hashed arguments. Valid keys are :sample_rate (reqd),
  #                    :max_delay_seconds (reqd) and :delay_seconds (not reqd).
  #                    See ARG_SPECS for more details.
  def initialize args
    hash_make DelayLine::ARG_SPECS, args
    raise ArgumentError, "delay_seconds #{delay_seconds} is greater than max_delay_seconds #{max_delay_seconds}" if @delay_seconds > @max_delay_seconds
    @buffer = CircularBuffer.new((@sample_rate * @max_delay_seconds) + 1, :override_when_full => true)
    @buffer.push_ary Array.new(@buffer.size, 0.0)
    self.delay_seconds=(@delay_seconds)
  end
  
  # Set the delay in seconds. Actual delay will vary according because an
  # integer number of delay samples is used.
  def delay_seconds= delay_seconds
    delay_samples_floor = (@sample_rate * delay_seconds).floor
    @delay_samples = delay_samples_floor.to_i
    @delay_seconds = delay_samples_floor / @sample_rate
  end
  
  # Push a new sample through the circular buffer, overriding the oldest.
  def push_sample sample
    @buffer.push sample
  end
  
  # Get the sample which is delayed by the number of samples that equates
  # to the set delay in seconds.
  def delayed_sample
    return @buffer.newest(@delay_samples)
  end
end
end
