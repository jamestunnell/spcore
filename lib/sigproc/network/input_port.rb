module SigProc
class InputPort
  include HashMake
  
  attr_reader :name, :continuous, :limit, :queue
  
  HASHED_ARGS = [
    HashedArg.new(:reqd => true, :key => :name, :type => String),
    HashedArg.new(:reqd => true, :key => :continuous, :type => Object),
    HashedArg.new(:reqd => false, :key => :limit, :type => Limit, :default => ->(){ Limit.new(Limit::TYPE_NONE, []) } ),
  ]

  def initialize args
    hash_make(args)
    
    @queue = []
  end

  def enqueue_values values
    for i in 0...values.count
      values[i] = @limit.limit(values[i])
    end
    
    @queue.concat values
  end
  
  def dequeue_values
    values = @queue
    @queue = []
    return values
  end

end
end