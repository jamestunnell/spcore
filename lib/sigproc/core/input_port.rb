module SigProc

class InputPort
  include HashMake
  
  attr_accessor :name, :continuous, :limit, :queue
  
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

  #private
  
  #attr_writer :name, :continuous, :limit

end

#class Port
#  
#  include HashMake
#  
#  attr_reader :name, :direction, :purpose, :limit, :value, :callback
#  
#  HASHED_ARGS = [
#    HashedArg.new(:reqd => true, :key => :name, :type => String),
#    HashedArg.new(:reqd => true, :key => :direction, :type => Symbol, :validator => ->(a){ ([a] & PORT_DIRECTIONS).any? } ),
#    HashedArg.new(:reqd => true, :key => :purpose, :type => Symbol, :validator => ->(a){ ([a] & PORT_PURPOSES).any? } ),
#    HashedArg.new(:reqd => false, :key => :limit, :type => Limit, :default => ->(a){ Limit.new(Limit::TYPE_NONE, []) } ),
#    #HashedArg.new(:reqd => true, :key => :limits, :type => Array, :validator => ->(a){ limits_valid?(a) } ),
#    HashedArg.new(:reqd => true, :key => :callback, :type => Proc),
#    HashedArg.new(:reqd => true, :key => :value, :type => Float),
#  ]
#
#  def initialize args
#    hash_make(args)
#  end
#
#  def value= value
#    
#    value = @limit.limit(value, @value)
#    
#    if value != @value
#      @callback.call(value)
#      @value = value
#    end
#
#  end
#    
#  private
#  
#  attr_writer :name, :direction, :purpose, :limit, :callback
#end
end
