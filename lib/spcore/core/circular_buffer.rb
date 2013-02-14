module SPCore
class CircularBuffer
  
  attr_accessor :fifo, :override_when_full
  attr_reader :fill_count
  
  def initialize size, opts = {}
    
    opts = { :fifo => true, :override_when_full => true }.merge opts
    
    @buffer = Array.new(size)
    @oldest = 0;
    @newest = 0;
    @fill_count = 0;

    @fifo = opts[:fifo]
    @override_when_full = opts[:override_when_full]
  end
  
  def size
    return @buffer.count
  end
  
  def empty?
    return @fill_count == 0
  end
  
  def full?
    return (@fill_count == size)
  end

  def resize size
    rv = false
    if(size != @buffer.count)
      rv = true
      @buffer = Array.new(size)
      @oldest = 0
      @newest = 0
      @fill_count = 0
    end
    return rv
  end
  
  def to_ary
    if empty?
      return []
    end

    # newest index is actually @newest - 1
    newest_idx = @newest - 1;
    if(newest_idx < 0)
      newest_idx += @buffer.count;
    end

    if newest_idx >= @oldest
      return @buffer[@oldest..newest_idx]
    else
      return @buffer[@oldest...@buffer.count] + @buffer[0..newest_idx]
    end
  end
  
  def push element
    if full?
      raise ArgumentError, "buffer is full, and override_when_full is false" unless @override_when_full
      
      @buffer[@newest] = element;
      @newest += 1
      @oldest += 1
    else
      @buffer[@newest] = element;
      @newest += 1
      @fill_count += 1      
    end

    if @oldest >= @buffer.count
      @oldest = 0
    end

    if @newest >= @buffer.count
      @newest = 0
    end
  end

  def push_ary ary
    ary.each do |element|
      push element
    end
  end

  def newest relative_index = 0
    raise ArgumentError, "buffer is empty" if empty?
    raise ArgumentError, "relative_index is greater or equal to @fill_count" if relative_index >= @fill_count

    # newestIdx is actually @newest - 1
    newestIdx = @newest - 1;
    if(newestIdx < 0)
      newestIdx += @buffer.count;
    end

    absIdx = newestIdx - relative_index;
    if(absIdx < 0)
      absIdx += @buffer.count;
    end

    return @buffer[absIdx];
  end
  
  def oldest relative_index = 0
    raise ArgumentError, "buffer is empty" if empty?
    raise ArgumentError, "relative_index is greater or equal to @fill_count" if relative_index >= @fill_count
    
    absIdx = @oldest + relative_index;
    if(absIdx >= @buffer.count)
        absIdx -= @buffer.count;
    end
    
    return @buffer[absIdx];
  end

  # Pop the oldest/newest element, depending on @fifo flag. When true, pop the oldest,
  # otherwise pop the newest. Set to true by default, can override during initialize or
  # later using fifo=.
  def pop
    raise ArgumentError, "buffer is empty" if empty?
    
    if @fifo
      # FIFO - pop the oldest element
      element = oldest
      @oldest += 1
      if(@oldest >= @buffer.count)
        @oldest = 0
      end
      @fill_count -= 1
      return element    
    else
      # FILO - pop the newest element
      element = newest
      if(@newest > 0)
        @newest -= 1
      else
        @newest = @buffer.count - 1
      end
      @fill_count -= 1
      return element      
    end
  end
end
end
