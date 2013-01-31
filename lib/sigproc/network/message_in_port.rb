module SigProc
class MessageInPort
  include HashMake
  
  DEFAULT_VALIDATOR = ->(a){ true }
  
  ARG_SPECS = [
    HashedArg.new(:reqd => false, :key => :name, :type => String, :default => "UNNAMED"),
    HashedArg.new(:reqd => true, :key => :processor, :type => Proc),
    HashedArg.new(:reqd => true, :key => :message_type, :type => Symbol, :validator => ->(a){ Message::TYPES.include?(a) })
  ]
  
  attr_reader :name, :link
  
  def initialize args
    hash_make MessageInPort::ARG_SPECS, args
    @queue = []
    @link = nil
  end
  
  def recv_message message
    raise ArgumentError, "message is not a Message" unless message.is_a?(Message)
    if message.type == @message_type
      return @processor.call(message)
    else
      raise ArgumentError, "message.type #{message.type} is not supported on this port"
    end
    
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
