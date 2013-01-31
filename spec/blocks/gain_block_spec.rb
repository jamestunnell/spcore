require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SigProc::GainBlock do
  describe '.new' do
    before :all do
      @block = SigProc::GainBlock.new
    end
    
    it 'should have default gain of 0 db' do
      @block.gain_db.should eq(0.0)
    end
    
    it 'should pass through values unchanged' do
      reciever = SigProc::SignalInPort.new
      values = [ 1.0, 2.0, -1.0 ]
      @block.signal_out_ports.first.add_link reciever
      @block.signal_in_ports.first.enqueue_values values
      @block.step
      reciever.queue.should eq(values)
    end
  end
end
