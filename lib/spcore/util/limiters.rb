module SPCore
# Provides methods to make limiting Proc objects, bound to
# the given limits.
class Limiters
  # make a limiter that actually doesn't limit at all.
  def self.make_no_limiter
    return lambda do |input|
      return input
    end
  end
  
  # make a limiter that keeps values within the given range.
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

  # make a limiter that keeps values at or below the given upper limit.
  def self.make_upper_limiter limit
    return lambda do |input|
      if input > limit
        return limit
      else
        return input
      end
    end
  end

  # make a limiter that keeps values at or above the given lower limit.
  def self.make_lower_limiter limit
    return lambda do |input|
      if input < limit
        return limit
      else
        return input
      end
    end
  end
  
  # make a limiter that limits values to a set of good values. Given also the
  # current value, it either returns the input value if it's included in
  # the set of good values, or it returns the current value.
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
