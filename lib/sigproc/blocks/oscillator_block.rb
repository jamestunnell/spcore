module SigProc
class OscillatorBlock < Block

  def initialize hashed_args = {}
    @oscillator = Oscillator.new(hashed_args)

    wave_type_limiter = Limiters.make_enum_limiter(Oscillator::WAVES)
    wave_type_handler = ControlMessage.make_handler(
      lambda { |message| message.data = @oscillator.wave_type },
      lambda { |message| @oscillator.wave_type = wave_type_limiter.call(message.data, @oscillator.wave_type) }
    )
    
    freq_limiter = Limiters.make_range_limiter(0.01..(@oscillator.sample_rate / 2.0))
    freq_handler = ControlMessage.make_handler(
      lambda { |message| message.data = @oscillator.frequency },
      lambda { |message| @oscillator.frequency = freq_limiter.call(message.data) }
    )

    ampl_handler = ControlMessage.make_handler(
      lambda { |message| message.data = @oscillator.amplitude },
      lambda { |message| @oscillator.amplitude = message.data }
    )

    phase_handler = ControlMessage.make_handler(
      lambda { |message| message.data = @oscillator.phase_offset },
      lambda { |message| @oscillator.phase_offset = message.data }
    )

    dc_handler = ControlMessage.make_handler(
      lambda { |message| message.data = @oscillator.dc_offset },
      lambda { |message| @oscillator.dc_offset = message.data }
    )
    
    output = SignalOutPort.new(:name => "OUTPUT")
    wave_type = MessageInPort.new(:name => "WAVE_TYPE", :message_type => Message::CONTROL, :processor => wave_type_handler)
    frequency = MessageInPort.new(:name => "FREQUENCY", :message_type => Message::CONTROL, :processor => freq_handler)
    amplitude = MessageInPort.new(:name => "AMPLITUDE", :message_type => Message::CONTROL, :processor => ampl_handler)
    phase_offset = MessageInPort.new(:name => "PHASE_OFFSET", :message_type => Message::CONTROL, :processor => phase_handler)
    dc_offset = MessageInPort.new(:name => "DC_OFFSET", :message_type => Message::CONTROL, :processor => dc_handler)
    
    algorithm = lambda do |count|
      values = Array.new(count)
      count.times do |i|
        values[i] = @oscillator.sample
      end
      output.send_values(values)
    end

    super_args = {
      :name => "DELAY",
      :algorithm => algorithm,
      :signal_in_ports => [ ],
      :signal_out_ports => [ output ],
      :message_in_ports => [ wave_type, frequency, amplitude, phase_offset, dc_offset ],
      :message_out_ports => []
    }
    super(super_args)
  end
end
end
