require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SigProc::DelayBlock do
  describe '.new' do
    before :all do
      @block = SigProc::DelayBlock.new :sample_rate => 200.0, :max_delay_sec => 1.0
    end
    
    it 'should have default delay time of 0.0 sec' do
      @block.delay_sec.should eq(0.0)
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
  
  describe "DELAY_SEC port" do
    it 'should set the delay in seconds' do
      sample_rate = 200.0
      max_delay_sec = 1.0
      5.times do
        @block = SigProc::DelayBlock.new(
          :sample_rate => sample_rate,
          :max_delay_sec => max_delay_sec
        )
        delay_sec = rand * max_delay_sec
        delay_samples = sample_rate * delay_sec
        rand_sample = rand

        @reciever = SigProc::SignalInPort.new
        @block.find_first_port("OUTPUT").add_link @reciever
        @values = [rand_sample] + Array.new(delay_samples, 0.0)
        @block.find_first_port("INPUT").enqueue_values @values
  
        @block.find_first_port("DELAY_SEC").recv_message(delay_sec)
        @block.step
        @reciever.queue.last.should eq(rand_sample)
      end
    end
  end
end
