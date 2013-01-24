require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SigProc::Processor do
  context '.new' do
    context 'no I/O ports given' do
      before :all do
        @processor = SigProc::Processor.new
      end
      
      it 'should have no input ports' do
        @processor.input_ports.should be_empty
      end

      it 'should have no output ports' do
        @processor.output_ports.should be_empty
      end
    end
  end
end