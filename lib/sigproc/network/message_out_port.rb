require 'set'

module SigProc
class MessageOutPort
  include HashMake
  
  ARG_SPECS = [
    HashedArg.new(:reqd => false, :key => :name, :type => String, :default => "UNNAMED"),
  ]
  
  attr_reader :name, :links
  
  def initialize args = {}
    hash_make MessageOutPort::ARG_SPECS, args
    @links = Set.new
  end
  
  def send_message message
    rvs = []
    @links.each do |link|
      rvs.push link.recv_message message
    end
    return rvs
  end
  
  def add_link link
    raise ArgumentError, "link #{link} is not a MessageInPort" unless link.is_a?(MessageInPort)
    raise ArgumentError, "link #{link} is already linked to a MessageInPort" if link.link
    @links.add link
    link.set_link self
  end
  
  def remove_link link
    raise ArgumentError, "link #{link} is not a MessageInPort" unless link.is_a?(MessageInPort)
    raise ArgumentError, "@links does not include link #{link}" unless @links.include? link
    @links.delete link
    link.clear_link
  end
  
  def remove_bad_links
    marked_for_removal = []
    
    @links.each do |link|
      bad = (link.link == nil) or (link.link != self)
      if bad
        marked_for_removal.push link
      end
    end
    
    marked_for_removal.each do |link|
      @links.delete link
    end
  end
end
end
