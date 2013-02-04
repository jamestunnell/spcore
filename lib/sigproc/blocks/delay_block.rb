module SigProc
class DelayBlock < SPNet::Block

  include Hashmake::HashMakeable
  
  HASHED_ARG_SPECS = [
    Hashmake::ArgSpec.new(:reqd => false, :key => :feedback, :type => Numeric, :default => 0.0, :validator => ->(a){ a.between? 0.0, 1.0 } ),
    Hashmake::ArgSpec.new(:reqd => false, :key => :mix, :type => Numeric, :default => 1.0, :validator => ->(a){ a.between? 0.0, 1.0 } ),
  ]

  def initialize hashed_args = {}
    hash_make DelayBlock::HASHED_ARG_SPECS, hashed_args
    
    @delay_line = DelayLine.new(hashed_args)
    
    delay_limiter = Limiters.make_range_limiter(0.0..@delay_line.max_delay_seconds)
    delay_sec_handler = SPNet::ControlMessage.make_handler(
      lambda {|message| message.data = @delay_line.delay_seconds },
      lambda { |message| @delay_line.delay_seconds = delay_limiter.call(message.data) }
    )

    feedback_limiter = Limiters.make_range_limiter(0.0..1.0)
    feedback_handler = SPNet::ControlMessage.make_handler(
      lambda {|message| message.data = @feedback },
      lambda { |message| @feedback = feedback_limiter.call(message.data) }
    )
    
    mix_limiter = Limiters.make_range_limiter(0.0..1.0)
    mix_handler = SPNet::ControlMessage.make_handler(
      lambda {|message| message.data = @mix },
      lambda { |message| @mix = mix_limiter.call(message.data) }
    )
    
    input = SPNet::SignalInPort.new(:name => "INPUT")
    output = SPNet::SignalOutPort.new(:name => "OUTPUT")
    delay_sec = SPNet::MessageInPort.new(:name => "DELAY_SEC", :message_type => SPNet::Message::CONTROL, :processor => delay_sec_handler)
    feedback = SPNet::MessageInPort.new(:name => "FEEDBACK", :message_type => SPNet::Message::CONTROL, :processor => feedback_handler)
    mix = SPNet::MessageInPort.new(:name => "MIX", :message_type => SPNet::Message::CONTROL, :processor => mix_handler)
    
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
