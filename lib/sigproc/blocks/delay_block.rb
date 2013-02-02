module SigProc
class DelayBlock < Block

  include HashMake
  
  HASHED_ARG_SPECS = [
    HashedArg.new(:reqd => false, :key => :feedback, :type => Numeric, :default => 0.0, :validator => ->(a){ a.between? 0.0, 1.0 } ),
    HashedArg.new(:reqd => false, :key => :mix, :type => Numeric, :default => 1.0, :validator => ->(a){ a.between? 0.0, 1.0 } ),
  ]

  def initialize hashed_args = {}
    hash_make DelayBlock::HASHED_ARG_SPECS, hashed_args
    
    @delay_line = DelayLine.new(hashed_args)
    
    delay_limiter = Limiters.make_range_limiter(0.0..@delay_line.max_delay_seconds)
    delay_sec_handler = ControlMessage.make_handler(
      lambda {|message| message.data = @delay_line.delay_seconds },
      lambda { |message| @delay_line.delay_seconds = delay_limiter.call(message.data) }
    )

    feedback_limiter = Limiters.make_range_limiter(0.0..1.0)
    feedback_handler = ControlMessage.make_handler(
      lambda {|message| message.data = @feedback },
      lambda { |message| @feedback = feedback_limiter.call(message.data) }
    )
    
    mix_limiter = Limiters.make_range_limiter(0.0..1.0)
    mix_handler = ControlMessage.make_handler(
      lambda {|message| message.data = @mix },
      lambda { |message| @mix = mix_limiter.call(message.data) }
    )
    
    input = SignalInPort.new(:name => "INPUT")
    output = SignalOutPort.new(:name => "OUTPUT")
    delay_sec = MessageInPort.new(:name => "DELAY_SEC", :message_type => Message::CONTROL, :processor => delay_sec_handler)
    feedback = MessageInPort.new(:name => "FEEDBACK", :message_type => Message::CONTROL, :processor => feedback_handler)
    mix = MessageInPort.new(:name => "MIX", :message_type => Message::CONTROL, :processor => mix_handler)
    
    algorithm = lambda do |count|
      values = input.dequeue_values count
      for i in 0...values.count
        input = values[i]
        delayed_before = @delay_line.delayed_sample
        @delay_line.push_sample(input + (@feedback * delayed_before))
        delayed_after = @delay_line.delayed_sample
        values[i] = (input * (1.0 - @mix)) + (delayed_after * @mix)
      end
      output.send_values(values)
    end

    super_args = {
      :name => "DELAY",
      :algorithm => algorithm,
      :signal_in_ports => [ input ],
      :signal_out_ports => [ output ],
      :message_in_ports => [ delay_sec, feedback, mix ],
      :message_out_ports => []
    }
    super(super_args)
  end
end
end
