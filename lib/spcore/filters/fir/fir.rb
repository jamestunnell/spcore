module SPCore
class FIR
  
  attr_reader :kernel, :order, :sample_rate
  
  def initialize kernel, sample_rate
    @kernel = kernel
    @order = kernel.size - 1
    @sample_rate = sample_rate
  end
  
  def convolve input
    kernel_size = @kernel.size
    raise ArgumentError, "input.size #{input.size} is not greater than filter kernel size #{kernel_size}" unless input.size > kernel_size
    
    output = Array.new(input.size, 0.0)

    for i in 0...kernel_size
      sum = 0.0
      # convolve the input with the filter kernel
      for j in 0...i
        sum += (input[j] * @kernel[kernel_size - (1 + i - j)])
      end
      output[i] = sum
    end
    
    for i in kernel_size...input.size
      sum = 0.0
      # convolve the input with the filter kernel
      for j in 0...kernel_size
        sum += (input[i-j] * @kernel[j])
      end
      output[i] = sum
    end
    
    return output
  end
  
  def freq_response use_db = false

    input = [0.0] + @kernel # make the size even
    output = FFT.forward input
    
    output = output[0...(output.size / 2)]  # ignore second half (mirror image)
    output = output.map {|x| x.magnitude }  # calculate magnitudes from complex values
    
    if use_db
      output = output.map {|x| Gain::linear_to_db x }
    end
    
    response = {}
    output.each_index do |n|
      frequency = (@sample_rate * n) / (output.size * 2)
      response[frequency] = output[n]
    end
    
    ## amplitude = 2 * f[j] / size
    #output = output.map {|x| 2 * x / output.size }
    
    return response
  end
  
  def plot_freq_response use_db = true
    plotter = Plotter.new(
      :title => "Freq magnitude response of #{@order}-order FIR filter",
      :xlabel => "frequency (Hz)",
      :ylabel => "magnitude#{use_db ? " (dB)" : ""}",
      :logscale => "x"
    )
    
    plotter.plot_2d "" => freq_response(use_db)
  end
end
end
