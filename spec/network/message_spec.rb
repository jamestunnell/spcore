require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SigProc::Message do
  describe '.new' do
    it 'should set data and type' do
      message = SigProc::Message.new :type => SigProc::Message::CONTROL, :data => 9
      message.type.should eq(SigProc::Message::CONTROL)
      message.data.should eq(9)
    end
  end
end
