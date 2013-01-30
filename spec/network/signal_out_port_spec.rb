require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SigProc::SignalOutPort do
  describe '.new' do
    it 'should have no links' do
      port = SigProc::SignalOutPort.new(:name => 'xyz')
      port.links.should be_empty
    end    
  end
  
  describe '#add_link' do
    it 'should add the given input port to links' do
      out_port = SigProc::SignalOutPort.new(:name => 'xyz')
      in_port = SigProc::SignalInPort.new(:name => 'abc')
      
      out_port.add_link in_port
      out_port.links.count.should be 1
      out_port.links.first.should eq(in_port)
    end

    it 'should also link the output port to the given input port' do
      out_port = SigProc::SignalOutPort.new(:name => 'xyz')
      in_port = SigProc::SignalInPort.new(:name => 'abc')
      
      out_port.add_link in_port
      in_port.link.should eq(out_port)
    end

    it 'should raise ArgumentError if the given input port is already linked' do
      out_port = SigProc::SignalOutPort.new(:name => 'xyz')
      in_port = SigProc::SignalInPort.new(:name => 'abc')
      
      out_port.add_link in_port
      lambda { out_port.add_link(in_port) }.should raise_error(ArgumentError)
    end
    
    it 'should raise ArgumentError if port is not input port' do
      out_port = SigProc::SignalOutPort.new(:name => 'xyz')
      out_port2 = SigProc::SignalOutPort.new(:name => 'abc')
      
      lambda { out_port.add_link(out_port2) }.should raise_error(ArgumentError)
    end
  end

  describe '#remove_link' do
    it 'should remove the given input port (if it is already linked to the output port)' do
      out_port = SigProc::SignalOutPort.new(:name => 'xyz')
      in_port = SigProc::SignalInPort.new(:name => 'abc')
      
      out_port.add_link in_port
      out_port.remove_link in_port
      out_port.links.should be_empty
    end
  end

  describe '#send_values' do
    context 'single linked input port' do
      it 'should enqueue the values on the linked input port' do
        out_port = SigProc::SignalOutPort.new(:name => 'xyz')
        in_port = SigProc::SignalInPort.new(:name => 'abc')
        
        out_port.add_link in_port
        
        in_port.queue.should be_empty
        out_port.send_values [1,2,3,4]
        in_port.queue.should eq([1,2,3,4])      
      end
    end

    context 'several linked input ports' do
      it 'should enqueue the values on each linked input port' do
        out_port = SigProc::SignalOutPort.new(:name => 'xyz')
        in_port1 = SigProc::SignalInPort.new(:name => 'abc')
        in_port2 = SigProc::SignalInPort.new(:name => 'def')
        in_port3 = SigProc::SignalInPort.new(:name => 'ghi')
        
        out_port.add_link in_port1
        out_port.add_link in_port2
        out_port.add_link in_port3
        
        in_port1.queue.should be_empty
        in_port2.queue.should be_empty
        in_port3.queue.should be_empty
        
        out_port.send_values [1,2,3,4]
        
        in_port1.queue.should eq([1,2,3,4])
        in_port2.queue.should eq([1,2,3,4])
        in_port3.queue.should eq([1,2,3,4])
      end
    end
  end

end
