module SigProc
class DelayBlock < Block
  include HashMake
  
  HASHED_ARG_SPECS = [
    HashedArg.new(:reqd => true, :key => :sample_rate, :type => Float, :validator => ->(a){ a >= 0.0 } ),
    HashedArg.new(:reqd => true, :key => :max_delay_sec, :type => Float, :validator => ->(a){ a > 0.0 } ),
    HashedArg.new(:reqd => false, :key => :delay_sec, :type => Float, :default => 0.0, :validator => ->(a){ a >= 0.0 } ),
  ]
  
  def delay_sec
    @delay_line.delay_seconds
  end
  
  def initialize args = {}
    hash_make DelayBlock::HASHED_ARG_SPECS, args
    @delay_line = DelayLine.new(
      :sample_rate => @sample_rate,
      :max_delay_seconds => @max_delay_sec,
      :delay_seconds => @delay_sec
    )
    
    limiter = Limiters.make_range_limiter(0..@delay_line.max_delay_seconds)
    set_delay_sec_handler = lambda do |message|
      @delay_line.delay_seconds = limiter.call(message.data)
    end

    get_delay_sec_handler = lambda do |message|
      message.data = @delay_line.delay_seconds
    end
    
    delay_sec_handler = ControlMessage.make_handler get_delay_sec_handler, set_delay_sec_handler
    
    input = SignalInPort.new(:name => "INPUT")
    output = SignalOutPort.new(:name => "OUTPUT")
    delay_sec = MessageInPort.new(:name => "DELAY_SEC", :message_type => Message::CONTROL, :processor => delay_sec_handler)
    
    algorithm = lambda do
      values = input.dequeue_values
      for i in 0...values.count
        @delay_line.push_sample values[i]
        values[i] = @delay_line.delayed_sample
      end
      output.send_values(values)
    end

    super_args = {
      :name => "DELAY",
      :algorithm => algorithm,
      :signal_in_ports => [ input ],
      :signal_out_ports => [ output ],
      :message_in_ports => [ delay_sec ],
      :message_out_ports => []
    }
    super(super_args)
  end
end
end
