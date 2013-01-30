require 'set'

module SigProc
class SignalOutPort
  include HashMake
  
  HASHED_ARGS = [
    HashedArg.new(:reqd => true, :key => :name, :type => String),
  ]
  
  attr_reader :name, :links
  
  def initialize args
    hash_make args
    @links = Set.new
  end
  
  def send_values values
    @links.each do |link|
      link.enqueue_values values
    end
  end
  
  def add_link link
    raise ArgumentError, "link #{link} is not a SignalInPort" unless link.is_a?(SignalInPort)
    raise ArgumentError, "link #{link} is already linked to a SignalOutPort" if link.link
    @links.add link
    link.set_link self
  end
  
  def remove_link link
    raise ArgumentError, "link #{link} is not a SignalInPort" unless link.is_a?(SignalInPort)
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
