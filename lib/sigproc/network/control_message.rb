module SigProc
class ControlMessage < Message

  include HashMake
  
  GET = :controlMessageSubtypeGet
  SET = :controlMessageSubtypeSet
  
  SUBTYPES = [
    GET,
    SET
  ]
  
  HASHED_ARGS_SPECS = [
    HashedArg.new(:reqd => true, :key => :subtype, :type => Symbol, :validator => ->(a){ SUBTYPES.include?(a) } )
  ]
  
  attr_reader :subtype
  
  def initialize hashed_args
    hash_make ControlMessage::HASHED_ARGS_SPECS, hashed_args
    super_hashed_args = hashed_args.merge! :type => Message::CONTROL
    super(super_hashed_args)
  end
  
  def self.make_handler get_handler, set_handler
    handler = lambda do |message|
      raise ArgumentError, "message is not a ControlMessage" unless message.is_a?(ControlMessage)
      
      if message.subtype == GET
        return get_handler.call message
      elsif message.subtype == SET
        return set_handler.call message
      else
        raise ArgumentError, "message subtype #{message.subtype} is not valid"
      end
      
    end
    return handler
  end
  
  def self.make_set_message data
    ControlMessage.new :subtype => SET, :data => data
  end

  def self.make_get_message
    ControlMessage.new :subtype => GET
  end
end
end