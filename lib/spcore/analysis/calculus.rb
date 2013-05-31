module SPCore
class Calculus
  # Differentiates the given values.
  #
  # @param [Array] values The input value series.
  # @param [Numeric] dt The time differential (i.e. the sample period)
  def self.derivative values, dt
    raise "values.size is <= 2" if values.size <= 2
    
    derivative = Array.new(values.size)
    
    for i in 1...values.count
      derivative[i] = (values[i] - values[i-1]) / dt
    end
    
    derivative[0] = derivative[1]
    return derivative
  end
  
  # Integrates the given values.
  #
  # @param [Array] values The input value series.
  # @param [Numeric] dt The time differential (i.e. the sample period)
  def self.integral values, dt
    raise "values.size is <= 2" if values.size <= 2
    
    integral = Array.new(values.size)
    
    integral[0] = values[0] * dt
    for i in 1...values.count
      integral[i] = (values[i] * dt) + integral[i-1]
    end
    
    return integral
  end
end
end
