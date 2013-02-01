module SigProc
class GainBlock < Block
  include HashMake
  
  GAIN_MIN = -Gain::MAX_DB_ABS
  GAIN_MAX = Gain::MAX_DB_ABS
  
  HASHED_ARG_SPECS = [
    HashedArg.new(:reqd => false, :key => :gain_db, :type => Float, :default => 0.0, :validator => ->(a){ a >= GAIN_MIN && a <= GAIN_MAX } ),
  ]
  
  def initialize args = {}
    hash_make HASHED_ARG_SPECS, args
    @gain_linear = Gain.db_to_linear @gain_db
    
    limiter = Limiters.make_range_limiter(GAIN_MIN..GAIN_MAX)
    set_gain_db_handler = lambda do |message|
      @gain_db = limiter.call(message.data)
      @gain_linear = Gain.db_to_linear @gain_db
    end
    
    get_gain_db_handler = lambda do |message|
      message.data = @gain_db
    end
    
    gain_db_handler = ControlMessage.make_handler get_gain_db_handler, set_gain_db_handler
    
    input = SignalInPort.new(:name => "INPUT")
    output = SignalOutPort.new(:name => "OUTPUT")
    gain_db = MessageInPort.new(:name => "GAIN_DB", :message_type => Message::CONTROL, :processor => gain_db_handler)
    
    algorithm = lambda do |count|
      values = input.dequeue_values count
      for i in 0...values.count
        values[i] *= @gain_linear
      end
      output.send_values(values)
    end

    super_args = {
      :name => "GAIN",
      :algorithm => algorithm,
      :signal_in_ports => [ input ],
      :signal_out_ports => [ output ],
      :message_in_ports => [ gain_db ],
      :message_out_ports => []
    }
    super(super_args)
  end
end
end
