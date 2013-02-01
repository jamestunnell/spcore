module SigProc
class Message
  
  include HashMake
  
  CONTROL = :messageTypeControl
  COMMAND = :messageTypeCommand
  
  TYPES = [ CONTROL, COMMAND ]
  
  HASHED_ARGS_SPECS = [
    HashedArg.new(:reqd => true, :key => :type, :type => Symbol, :validator => ->(a){ TYPES.include?(a) } ),
    HashedArg.new(:reqd => false, :key => :data, :type => Object, :default => nil),
  ]
  
  attr_accessor :data
  attr_reader :type
  
  def initialize hashed_args = {}
    hash_make Message::HASHED_ARGS_SPECS, hashed_args
  end
end
end
