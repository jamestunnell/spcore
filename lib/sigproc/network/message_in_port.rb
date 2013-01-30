module SigProc
class MessageInPort
  include HashMake
  
  DEFAULT_VALIDATOR = ->(a){ true }
  
  HASHED_ARGS = [
    HashedArg.new(:reqd => false, :key => :name, :type => String, :default => "UNNAMED"),
    HashedArg.new(:reqd => true, :key => :processor, :type => Proc),
  ]
  
  attr_reader :name, :link
  
  def initialize args
    hash_make args
    @queue = []
    @link = nil
  end
  
  def recv_message message
    return @processor.call(message)
  end
  
  def clear_link
    @link = nil
  end
  
  def set_link link
    raise ArgumentError, "link #{link} is not a MessageOutPort" unless link.is_a?(MessageOutPort)
    @link = link
  end

end
end
