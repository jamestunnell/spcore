module SigProc
class Limiters
  def self.make_no_limiter
    return lambda do |input|
      return input
    end
  end
    
  def self.make_range_limiter range
    return lambda do |input|
      if input < range.first
        return range.first
      elsif input > range.last
        return range.last
      else
        return input
      end
    end
  end

  def self.make_upper_limiter limit
    return lambda do |input|
      if input > limit
        return limit
      else
        return input
      end
    end
  end

  def self.make_lower_limiter limit
    return lambda do |input|
      if input < limit
        return limit
      else
        return input
      end
    end
  end
  
  def self.make_enum_limiter good_values
    return lambda do |input, current|
      if good_values.include?(input)
        return input
      else
        return current
      end
    end
  end
end
end
