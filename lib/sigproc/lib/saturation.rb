module SigProc
class Saturation
  # Sigmoid-based saturation when input is above threshold.
  # From musicdsp.org, posted by Bram.
  def self.sigmoid input, threshold
    input_abs = input.abs
    if input_abs < threshold
      return input
    else
      #y = threshold + (1.0 - threshold) * mock_sigmoid((input_abs - threshold) / ((1.0 - threshold) * 1.5))
      y = threshold + (1.0 - threshold) * Math::tanh((input_abs - threshold)/(1-threshold))
      
      if input > 0.0
        return y
      else
        return -y
      end
    end
  end
  
  def self.gompertz input, threshold
    a = threshold
    b = -4
    c = -2
    x = input.abs
    y = 2 * a * Math::exp(b * Math::exp(c * x))
    
    if input > 0.0
      return y
    else
      return -y
    end
  end
  
  private
  
  #def self.mock_sigmoid x
  #  if(x.abs < 1.0)
  #    return x * (1.5 - 0.5 * x * x)
  #  else
  #    return x > 0.0 ? 1.0 : -1.0
  #  end
  #end
end
end
