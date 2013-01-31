require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SigProc::ControlMessage do
  describe '.new' do
    it 'should set type to Message::CONTROL' do
      message = SigProc::ControlMessage.new :subtype => SigProc::ControlMessage::GET
      message.type.should eq(SigProc::Message::CONTROL)
    end
    
    it 'should ignore attempt to override type' do
      message = SigProc::ControlMessage.new :subtype => SigProc::ControlMessage::GET, :type => :fakeType
      message.type.should eq(SigProc::Message::CONTROL)
    end
    
    it 'should allow data to be set' do
      message = SigProc::ControlMessage.new :subtype => SigProc::ControlMessage::GET, :data => 17
      message.data.should eq(17)
    end
  end
  
  describe '.make_set_message' do
    it 'should set data' do
      message = SigProc::ControlMessage.make_set_message 18
      message.data.should eq(18)
    end
    
    it 'should set subtype to ControlMessage::SET' do
      message = SigProc::ControlMessage.make_set_message 18
      message.subtype.should eq(SigProc::ControlMessage::SET)
    end
  end

  describe '.make_get_message' do
    it 'should set subtype to ControlMessage::GET' do
      message = SigProc::ControlMessage.make_get_message
      message.subtype.should eq(SigProc::ControlMessage::GET)
    end
  end

end
