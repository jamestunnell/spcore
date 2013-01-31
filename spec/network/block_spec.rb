require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SigProc::Block do
  context '.new' do
    context 'no I/O ports given' do
      before :all do
        @block = SigProc::Block.new
      end
      
      it 'should have no input ports' do
        @block.signal_in_ports.should be_empty
      end

      it 'should have no output ports' do
        @block.signal_out_ports.should be_empty
      end
    end
    
    context '1 signal in and 1 signal out port given' do
      before :all do
        @block = SigProc::Block.new(
          :signal_in_ports => [SigProc::SignalInPort.new(:name => "IN")],
          :signal_out_ports => [SigProc::SignalOutPort.new(:name => "OUT")],
        )
      end
      
      it 'should have no input ports' do
        @block.signal_in_ports.count.should be 1
        @block.signal_in_ports.first.name.should eq("IN")
      end

      it 'should have no output ports' do
        @block.signal_out_ports.count.should be 1
        @block.signal_out_ports.first.name.should eq("OUT")
      end      
    end
  end
end
