require 'wavefile'
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SigProc::FileOutBlock do
  describe 'writing a file' do
    it 'should write values that can be read back later' do
      filename = "file_out_block_spec.wav"
      block = SigProc::FileOutBlock.new :sample_rate => 22050.0, :file_name => filename
      values = [0.1,0.2,0.3,0.4,0.5]
      block.find_first_port("INPUT").enqueue_values values
      block.step values.count
      block.close
      #close_msg = SigProc::CommandMessage.new :command => SigProc::FileOutBlock::CLOSE
      #block.find_first_port("COMMANDS").recv_message close_msg
      
      reader = WaveFile::Reader.new(filename).each_buffer(values.size) do |buffer|
        converted_samples = buffer.samples.map {|sample| sample.to_f / SigProc::FileOutBlock::MAX_SAMPLE_VALUE }
        converted_samples.each_index do |i|
          converted_samples[i].should be_within(1e-9).of(values[i])
        end
      end
    end    
  end
end
