module SigProc
class Processor
  include HashMake
  
  attr_reader :name, :signal_in_ports, :signal_out_ports
  
  HASHED_ARGS = [
    HashedArg.new(:reqd => false, :key => :name, :type => String, :default => "UNNAMED"),
    HashedArg.new(:reqd => false, :key => :signal_in_ports, :type => SignalInPort, :array => true, :default => ->(){ Array.new } ),
    HashedArg.new(:reqd => false, :key => :signal_out_ports, :type => SignalOutPort, :array => true, :default => ->(){ Array.new })
  ]
  
  def initialize args = {}
    hash_make(args)
  end
end
end
