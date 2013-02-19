module SPCore
# Provide simple saturation methods, that limit input above the given threshold value.
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
  
  # A Gompertz-sigmoid-based saturation when input is above threshold.
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
  
end
end
