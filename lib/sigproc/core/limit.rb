module SigProc
class Limit
  attr_reader :limit_type, :limit_values

  TYPE_NONE = :limitTypeNone
  TYPE_LOWER = :limitTypeLower
  TYPE_UPPER = :limitTypeUpper
  TYPE_RANGE = :limitTypeRange
  TYPE_ENUM = :limitTypeEnum
  TYPES = [ TYPE_NONE, TYPE_LOWER, TYPE_UPPER, TYPE_RANGE, TYPE_ENUM ]
  
  def initialize limit_type, limit_values
    raise ArgumentError, "limit type #{limit_type} is not contained in Limit::TYPES" unless TYPES.include?(limit_type)
    @limit_type = limit_type
    raise ArgumentError, "limit values #{limit_values} are not valid for limit type #{@limit_type}" unless limit_values_valid?(limit_values)
    @limit_values = limit_values
  end

  def limit value
    
    case @limit_type
    when TYPE_NONE
    when TYPE_LOWER
      lower = @limit_values[0]
      value = (value > lower) ? value : lower
    when TYPE_UPPER
      upper = @limit_values[0]
      value = (value < upper) ? value : upper
    when TYPE_RANGE
      lower = @limit_values[0]
      upper = @limit_values[1]
      
      if value < lower
        value = lower
      elsif value > upper
        value = upper
      end
    when TYPE_ENUM
      lowest_diff = (@limit_values[0] - value).abs
      lowest_diff_at = 0

      for i in 1...@limit_values.count do
        diff = (@limit_values[i] - value).abs
        if(diff < lowest_diff)
          lowest_diff = diff
          lowest_diff_at = i
        end
      end

      value = @limit_values[lowest_diff_at]
      
      #matched = false
      #@limit_values.each do |limit_value|
      #  if value == limit_value
      #    matched = true
      #    break
      #  end
      #end
      #
      #unless matched
      #  value = current_val
      #end
    end
    
    return value
  end

  private
  
  def limit_values_valid? limit_values
    count = limit_values.count
    
    case @limit_type
    when TYPE_NONE
      return count == 0
    when TYPE_LOWER
      return count == 1
    when TYPE_UPPER
      return count == 1
    when TYPE_RANGE
      return (count == 2) && (limit_values[1] > limit_values[0])
    when TYPE_ENUM
      return (count >= 1) && (count == limit_values.uniq.count)
    else
      raise "limit type #{@limit_type} is not expected"
    end
  end
  
end
end
