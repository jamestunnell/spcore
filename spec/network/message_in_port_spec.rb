require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SigProc::MessageInPort do
  describe '#recv_message' do
    before :all do
      processor = lambda do |message|
        return message
      end
      @port = SigProc::MessageInPort.new :processor => processor
    end
    
    it 'should pass the given message to the processing callback' do
      rv = @port.recv_message 5
      rv.should eq(5)
    end
  end
end
