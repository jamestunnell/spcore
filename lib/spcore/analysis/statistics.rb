module SPCore
# Statistical analysis methods.
class Statistics
  # Compute the mean of a value series.
  def self.sum values
    return values.inject(0){ |s, x| s + x }
  end
  
  # Compute the mean of a value series.
  def self.mean values
    return Statistics.sum(values) / values.size
  end
  
  # Compute the standard deviation of a value series.
  def self.std_dev values
    size = values.size
    raise ArgumentError, "size is <= 1" if size <= 1
    
    mean = Statistics.mean values
    total_dist_from_mean = values.inject(0){|sum,x| sum + (x - mean)**2}
    return Math.sqrt(total_dist_from_mean / (size - 1))
  end
  
  # Determines the normalized cross-correlation of a feature with an image.
  #
  # Normalization is from -1 to +1, where +1 is high correlation, -1 is high
  # correlation (of inverse), and 0 is no correlation.
  #
  # For autocorrelation, just cross-correlate a signal with itself.
  #
  # @param [Array] image The values which are actually recieved/measured.
  # @param [Array] feature The values to be searched for in the image. Size must
  #                not be greater than size of image.
  # @param [Fixnum] zero_padding Number of zeros to surround the image with.
  def self.correlation image, feature, zero_padding = 0
    raise ArgumentError, "feature size is > image size" if feature.size > image.size
    
    unless zero_padding == 0
      image = Array.new(zero_padding, 0) + image + Array.new(zero_padding, 0)
    end
    
    feature_mean = feature.inject(0){ |s, x| s + x } / feature.size.to_f
    feature_diff = feature.map {|x| x - feature_mean }
    sx = feature_diff.inject(0){ |s, x| s + x**2 }
    
    data = []
    for i in 0...(1 + image.size - feature.size)
      region = image[i...(i + feature.size)]
      region_mean = region.inject(0){|s,x| s + x } / feature.size.to_f
      region_diff = region.map {|x| x - region_mean }
      sy = region_diff.inject(0){ |s, x| s + x**2 }
      
      if sx == 0 || sy == 0
        if sx == 0 && sy == 0
          data.push 1.0
        else
          data.push 0.0
        end
        
        next
      end
        
      denom = Math.sqrt(sx*sy)
      
      sum = 0
      feature.size.times do |j|
        sum += (region_diff[j] * feature_diff[j])
      end
      
      r = sum / denom
      data.push(r)
    end
    
    return data
  end

end
end
