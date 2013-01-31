require 'pry'
module SigProc
class Block
  include HashMake
  
  attr_reader :name, :signal_in_ports, :signal_out_ports, :message_in_ports, :message_out_ports
  
  DO_NOTHING = ->(){}
  
  HASHED_ARG_SPECS = [
    HashedArg.new(:reqd => false, :key => :name, :type => String, :default => "UNNAMED"),
    HashedArg.new(:reqd => false, :key => :algorithm, :type => Proc, :default => DO_NOTHING),
    HashedArg.new(:reqd => false, :key => :signal_in_ports, :type => SignalInPort, :array => true, :default => ->(){ Array.new } ),
    HashedArg.new(:reqd => false, :key => :signal_out_ports, :type => SignalOutPort, :array => true, :default => ->(){ Array.new }),
    HashedArg.new(:reqd => false, :key => :message_in_ports, :type => MessageInPort, :array => true, :default => ->(){ Array.new }),
    HashedArg.new(:reqd => false, :key => :message_out_ports, :type => MessageOutPort, :array => true, :default => ->(){ Array.new })
  ]
  
  def initialize args = {}
    hash_make Block::HASHED_ARG_SPECS, args
  end
  
  def step
    @algorithm.call
  end
end
end
