require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SigProc::CircularBuffer do
  context '.new' do
    it 'should set buffer size but fill count should be zero' do
      [0,20,100].each do |size|
        buffer = SigProc::CircularBuffer.new size
        buffer.empty?.should be_true
        buffer.size.should eq(size)
      end
    end
  end
  
  describe '#push' do
    it 'should report full after buffer.size calls to #push' do
      [0,20,100].each do |size|
        buffer = SigProc::CircularBuffer.new size
        
        size.times do
          buffer.push rand
        end
        
        buffer.full?.should be_true
      end
    end
  end
  
  describe '#pop' do
    it 'should, with fifo set to true, after a series of pushes, report the first element pushed' do
      elements = [1,2,3,4,5]
      buffer = SigProc::CircularBuffer.new elements.count, :fifo => true
      elements.each do |element|
        buffer.push element
      end
      buffer.pop.should eq(elements.first)
    end

    it 'should, with fifo set to false, after a series of pushes, report the last element pushed' do
      elements = [1,2,3,4,5]
      buffer = SigProc::CircularBuffer.new elements.count, :fifo => false
      elements.each do |element|
        buffer.push element
      end
      buffer.pop.should eq(elements.last)
    end
  end
  
  describe '#newest' do
    it 'should, after a series of pushes, report the last element pushed' do
      elements = [1,2,3,4,5]
      buffer = SigProc::CircularBuffer.new elements.count
      elements.each do |element|
        buffer.push element
      end
      buffer.newest.should eq(elements.last)
    end
    
    it 'should, with fifo set to true, after a series of pushes and then a pop, report the last element pushed' do
      elements = [1,2,3,4,5]
      buffer = SigProc::CircularBuffer.new elements.count, :fifo => true
      elements.each do |element|
        buffer.push element
      end
      buffer.pop
      buffer.newest.should eq(elements.last)
    end

    it 'should, with fifo set to false, after a series of pushes and then a pop, report the second to last element pushed' do
      elements = [1,2,3,4,5]
      buffer = SigProc::CircularBuffer.new elements.count, :fifo => false
      elements.each do |element|
        buffer.push element
      end
      buffer.pop
      buffer.newest.should eq(elements[-2])
    end
  end
  
  describe '#oldest' do
    it 'should, after a series of pushes, report the first element pushed' do
      elements = [1,2,3,4,5]
      buffer = SigProc::CircularBuffer.new elements.count
      elements.each do |element|
        buffer.push element
      end
      buffer.oldest.should eq(elements.first)
    end
    
    it 'should, with fifo set to true, after a series of pushes and then a pop, report the second element pushed' do
      elements = [1,2,3,4,5]
      buffer = SigProc::CircularBuffer.new elements.count, :fifo => true
      elements.each do |element|
        buffer.push element
      end
      buffer.pop
      buffer.oldest.should eq(elements[1])
    end

    it 'should, with fifo set to false, after a series of pushes and then a pop, report the first element pushed' do
      elements = [1,2,3,4,5]
      buffer = SigProc::CircularBuffer.new elements.count, :fifo => false
      elements.each do |element|
        buffer.push element
      end
      buffer.pop
      buffer.oldest.should eq(elements.first)
    end
  end
end
