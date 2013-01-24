module SigProc
class Processor
  include HashMake
  
  attr_accessor :name, :input_ports, :output_ports
  
  HASHED_ARGS = [
    HashedArg.new(:reqd => false, :key => :name, :type => String, :default => "UNNAMED"),
    HashedArg.new(:reqd => false, :key => :input_ports, :type => InputPort, :array => true, :default => ->(){ Array.new } ),
    HashedArg.new(:reqd => false, :key => :output_ports, :type => OutputPort, :array => true, :default => ->(){ Array.new })
  ]
  
  def initialize args = {}
    hash_make(args)
  end
end
end
