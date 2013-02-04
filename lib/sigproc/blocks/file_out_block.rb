require 'spnet'
require 'wavefile'

module SigProc
class FileOutBlock < SPNet::Block

  include Hashmake::HashMakeable
  
  HASHED_ARG_SPECS = [
    Hashmake::ArgSpec.new(:reqd => true, :key => :sample_rate, :type => Float, :validator => ->(a){ (a > 0.0) && (a.to_i == a)} ),
    Hashmake::ArgSpec.new(:reqd => true, :key => :file_name, :type => String, :validator => ->(a){ !a.empty?() } ),
  ]

  BITS_PER_SAMPLE = 32
  MAX_SAMPLE_VALUE = (2 **(0.size * 8 - 2) - 2)

  def close
    @writer.close
  end
  
  def closed?
    @writer.closed?
  end
  
  def open
    unless closed?
      close
    end
    @writer = WaveFile::Writer.new(@file_name, @format)
  end
  
  def initialize hashed_args = {}
    hash_make HASHED_ARG_SPECS, hashed_args

    @format = WaveFile::Format.new(:mono, 32, @sample_rate.to_i)
    @writer = WaveFile::Writer.new(@file_name, @format)

    input = SPNet::SignalInPort.new(:name => "INPUT", :limits => (-1.0...1.0))
    algorithm = lambda do |count|
      values = input.dequeue_values count
      unless closed?
        int_values = values.map { |value| (value * MAX_SAMPLE_VALUE).to_i }
        buffer = WaveFile::Buffer.new(int_values, @format)
        @writer.write(buffer)
      end
    end

    super_args = {
      :name => "FILE_IN",
      :algorithm => algorithm,
      :signal_in_ports => [ input ],
      :signal_out_ports => [ ],
      :message_in_ports => [ ],
      :message_out_ports => [ ]
    }
    super(super_args)

  end
end
end
