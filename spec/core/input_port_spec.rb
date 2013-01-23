require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SigProc::InputPort do
  describe 'enqueue_values' do
    it 'should add values to queue' do
      port = SigProc::InputPort.new(:name => 'xyz', :continuous => true)
      values = [2.4, 2.6, 4.9, 5.1]
      
      port.enqueue_values(values.clone)
      values.should eq(port.queue)
    end
  
    it 'should limit all values before queuing them' do
      limit = SigProc::Limit.new(SigProc::Limit::TYPE_RANGE, [2.5, 5.0])
      port = SigProc::InputPort.new(:name => 'xyz', :continuous => true, :limit => limit)
      port.enqueue_values([2.4, 2.6, 4.9, 5.1])
      port.queue.each do |value|
        value.should be_between(2.5,5.0)
      end
    end
  end

  describe 'dequeue_values' do
    it 'should remove all values from queue' do
      port = SigProc::InputPort.new(:name => 'xyz', :continuous => true)
      values = [2.4, 2.6, 4.9, 5.1]
      port.enqueue_values(values.clone)
      values2 = port.dequeue_values
      port.queue.should be_empty
      values2.should eq(values)
    end
  end

end
