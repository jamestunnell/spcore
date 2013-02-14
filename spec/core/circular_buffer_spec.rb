require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SPCore::CircularBuffer do
  context '.new' do
    it 'should set buffer size but fill count should be zero' do
      [0,20,100].each do |size|
        buffer = SPCore::CircularBuffer.new size
        buffer.empty?.should be_true
        buffer.size.should eq(size)
      end
    end
  end
  
  describe '#push' do
    it 'should report full after buffer.size calls to #push' do
      [0,20,100].each do |size|
        buffer = SPCore::CircularBuffer.new size
        
        size.times do
          buffer.push rand
        end
        
        buffer.full?.should be_true
      end
    end
  end

  describe '#push_ary' do
    it 'should add the given array' do
      elements = [1,2,3,4,5,6]
      buffer = SPCore::CircularBuffer.new elements.count
      buffer.push_ary elements
      buffer.to_ary.should eq(elements)
    end
  end
  
  describe '#pop' do
    it 'should, with fifo set to true, after a series of pushes, report the first element pushed' do
      elements = [1,2,3,4,5]
      buffer = SPCore::CircularBuffer.new elements.count, :fifo => true
      elements.each do |element|
        buffer.push element
      end
      buffer.pop.should eq(elements.first)
    end

    it 'should, with fifo set to false, after a series of pushes, report the last element pushed' do
      elements = [1,2,3,4,5]
      buffer = SPCore::CircularBuffer.new elements.count, :fifo => false
      elements.each do |element|
        buffer.push element
      end
      buffer.pop.should eq(elements.last)
    end
  end
  
  describe '#newest' do
    it 'should, after a series of pushes, report the last element pushed' do
      elements = [1,2,3,4,5]
      buffer = SPCore::CircularBuffer.new elements.count
      elements.each do |element|
        buffer.push element
      end
      buffer.newest.should eq(elements.last)
    end
    
    it 'should, with fifo set to true, after a series of pushes and then a pop, report the last element pushed' do
      elements = [1,2,3,4,5]
      buffer = SPCore::CircularBuffer.new elements.count, :fifo => true
      elements.each do |element|
        buffer.push element
      end
      buffer.pop
      buffer.newest.should eq(elements.last)
    end

    it 'should, with fifo set to false, after a series of pushes and then a pop, report the second to last element pushed' do
      elements = [1,2,3,4,5]
      buffer = SPCore::CircularBuffer.new elements.count, :fifo => false
      elements.each do |element|
        buffer.push element
      end
      buffer.pop
      buffer.newest.should eq(elements[-2])
    end
    
    it 'should, when given a relative index, report the element reverse-indexed from the newest' do
      elements = [1,2,3,4,5]
      buffer = SPCore::CircularBuffer.new elements.count, :fifo => false
      elements.each do |element|
        buffer.push element
      end
      
      for i in 0...elements.count do
        buffer.newest(i).should eq(elements[elements.count - 1 - i])
      end
    end
  end
  
  describe '#oldest' do
    it 'should, after a series of pushes, report the first element pushed' do
      elements = [1,2,3,4,5]
      buffer = SPCore::CircularBuffer.new elements.count
      elements.each do |element|
        buffer.push element
      end
      buffer.oldest.should eq(elements.first)
    end
    
    it 'should, with fifo set to true, after a series of pushes and then a pop, report the second element pushed' do
      elements = [1,2,3,4,5]
      buffer = SPCore::CircularBuffer.new elements.count, :fifo => true
      elements.each do |element|
        buffer.push element
      end
      buffer.pop
      buffer.oldest.should eq(elements[1])
    end

    it 'should, with fifo set to false, after a series of pushes and then a pop, report the first element pushed' do
      elements = [1,2,3,4,5]
      buffer = SPCore::CircularBuffer.new elements.count, :fifo => false
      elements.each do |element|
        buffer.push element
      end
      buffer.pop
      buffer.oldest.should eq(elements.first)
    end
    
    it 'should, when given a relative index, report the element reverse-indexed from the newest' do
      elements = [1,2,3,4,5]
      buffer = SPCore::CircularBuffer.new elements.count, :fifo => false
      elements.each do |element|
        buffer.push element
      end
      
      for i in 0...elements.count do
        buffer.oldest(i).should eq(elements[i])
      end
    end
  end
  
  describe '#to_ary' do
    it 'should produce an empty array for an empty buffer' do
      buffer = SPCore::CircularBuffer.new 10
      buffer.to_ary.should be_empty
    end
    
    it 'should, after pushing an array of elements, produce an array of the same elements' do
      elements = [1,2,3,4,5]
      buffer = SPCore::CircularBuffer.new elements.count, :fifo => true
      elements.each do |element|
        buffer.push element
      end
      buffer.to_ary.should eq(elements)
    end

    it 'should, after pushing and popping an array of elements several times and then pushing the array one last time, produce an array of the same elements' do
      elements = [1,2,3,4,5]
      buffer = SPCore::CircularBuffer.new(3 * elements.count, :fifo => true)
      
      5.times do
        elements.each do |element|
          buffer.push element
        end
        elements.count.times do
          buffer.pop
        end
      end

      elements.each do |element|
        buffer.push element
      end
      buffer.to_ary.should eq(elements)
    end
  end
end
