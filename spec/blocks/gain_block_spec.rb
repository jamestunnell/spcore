require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SigProc::GainBlock do
  describe '.new' do
    before :all do
      @block = SigProc::GainBlock.new
    end
    
    it 'should have default gain of 0 db' do
      message = SigProc::ControlMessage.make_get_message
      @block.find_first_port("GAIN_DB").recv_message(message)
      message.data.should eq(0.0)
    end
    
    it 'should pass through values unchanged' do
      reciever = SigProc::SignalInPort.new
      values = [ 1.0, 2.0, -1.0 ]
      @block.signal_out_ports.first.add_link reciever
      @block.signal_in_ports.first.enqueue_values values
      @block.step 3
      reciever.queue.should eq(values)
    end
  end
  
  describe "GAIN_DB port" do
    before :each do
      @block = SigProc::GainBlock.new
      @reciever = SigProc::SignalInPort.new
      @block.signal_out_ports.first.add_link @reciever
      @values = [ 1.0, 2.0, -1.0 ]
      @block.signal_in_ports.first.enqueue_values @values
    end

    it 'should set gain to -20.0' do
      message = SigProc::ControlMessage.make_set_message(-20.0)
      @block.find_first_port("GAIN_DB").recv_message(message)
      @block.step 3
      @reciever.queue.first.should eq(SigProc::Gain.db_to_linear(-20.0) * @values.first)
    end
    
    it 'should set gain to +20.0' do
      message = SigProc::ControlMessage.make_set_message(20.0)
      @block.find_first_port("GAIN_DB").recv_message(message)
      @block.step 3
      @reciever.queue.first.should eq(SigProc::Gain.db_to_linear(20.0) * @values.first)
    end
  end
end
