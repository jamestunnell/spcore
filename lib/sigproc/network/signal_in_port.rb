module SigProc
class SignalInPort
  include HashMake
  
  DEFAULT_LIMITS = (-Float::MAX..Float::MAX)
  
  HASHED_ARGS = [
    HashedArg.new(:reqd => true, :key => :name, :type => String),
    HashedArg.new(:reqd => false, :key => :limits, :type => Range, :default => DEFAULT_LIMITS)
  ]
  
  attr_reader :name, :limits, :link, :queue
  
  def initialize args
    hash_make args
    @queue = []
    @skip_limiting = (@limits == DEFAULT_LIMITS)
    @limiter = Limiters.make_range_limiter @limits
    @link = nil
  end
  
  def enqueue_values values
    unless @skip_limiting
      for i in 0...values.count
        values[i] = @limiter.call(values[i])
      end
    end
    
    @queue.concat values
  end
  
  def dequeue_values count = @queue.count
    raise ArgumentError, "count is greater than @queue.count" if count > @queue.count
    @queue.slice!(0...count)
  end
  
  def clear_link
    @link = nil
  end
  
  def set_link link
    raise ArgumentError, "link #{link} is not a SignalOutPort" unless link.is_a?(SignalOutPort)
    @link = link
  end
end
end
