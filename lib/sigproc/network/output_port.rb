require 'set'

module SigProc
class OutputPort
  include HashMake
  
  attr_reader :name, :continuous, :links
  
  HASHED_ARGS = [
    HashedArg.new(:reqd => true, :key => :name, :type => String),
    HashedArg.new(:reqd => true, :key => :continuous, :type => Object)
  ]

  def initialize args
    hash_make(args)
    @links = Set.new
  end

  def add_link input_port
    raise ArgumentError, "input_port.continuous is not #{true == @continuous}" if input_port.continuous != @continuous
    @links.add input_port
  end
  
  def remove_link input_port
    @links.delete input_port
  end

  def send_values values
    @links.each do |link|
      link.enqueue_values values
    end
  end
end
end