module SigProc
class GainBlock < Block
  include HashMake
  
  GAIN_MIN = -Gain::MAX_DB_ABS
  GAIN_MAX = Gain::MAX_DB_ABS
  
  HASHED_ARG_SPECS = [
    HashedArg.new(:reqd => false, :key => :gain_db, :type => Float, :default => 0.0, :validator => ->(a){ a >= GAIN_MIN && a <= GAIN_MAX } ),
  ]
  
  attr_reader :gain_db
  
  def initialize args = {}
    hash_make HASHED_ARG_SPECS, args
    @gain_linear = Gain.db_to_linear @gain_db
    
    limiter = Limiters.make_range_limiter(GAIN_MIN..GAIN_MAX)
    gain_db_handler = lambda do |gain_db|
      @gain_db = limiter.call(gain_db)
      @gain_linear = Gain.db_to_linear @gain_db
    end
    
    input = SignalInPort.new(:name => "INPUT")
    output = SignalOutPort.new(:name => "OUTPUT")
    gain_db = MessageInPort.new(:name => "GAIN_DB", :processor => gain_db_handler)
    
    algorithm = lambda do
      values = input.dequeue_values
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