module SigProc
class DelayLine
  include Hashmake::HashMakeable
  
  attr_reader :sample_rate, :max_delay_seconds, :delay_seconds, :delay_samples
  
  ARG_SPECS = [
    Hashmake::ArgSpec.new(:reqd => true, :key => :sample_rate, :type => Float, :validator => ->(a){ a > 0.0 } ),
    Hashmake::ArgSpec.new(:reqd => true, :key => :max_delay_seconds, :type => Float, :validator => ->(a){ (a > 0.0) } ),
    Hashmake::ArgSpec.new(:reqd => false, :key => :delay_seconds, :type => Float, :default => 0.0, :validator => ->(a){ a >= 0.0 } ),
  ]
  
  def initialize args
    hash_make DelayLine::ARG_SPECS, args
    raise ArgumentError, "delay_seconds #{delay_seconds} is greater than max_delay_seconds #{max_delay_seconds}" if @delay_seconds > @max_delay_seconds
    @buffer = CircularBuffer.new((@sample_rate * @max_delay_seconds) + 1, :override_when_full => true)
    @buffer.push_ary Array.new(@buffer.size, 0.0)
    self.delay_seconds=(@delay_seconds)
  end
  
  def delay_seconds= delay_seconds
    delay_samples_floor = (@sample_rate * delay_seconds).floor
    @delay_samples = delay_samples_floor.to_i
    @delay_seconds = delay_samples_floor / @sample_rate
    
    #if @buffer.fill_count < @delay_samples
    #  @buffer.push_ary Array.new(@delay_samples - @buffer.fill_count, 0.0)
    #end
  end
  
  def push_sample sample
    @buffer.push sample
  end
  
  def delayed_sample
    return @buffer.newest(@delay_samples)
  end
end
end
