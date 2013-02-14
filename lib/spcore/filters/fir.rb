module SPCore
class FIR
  
  attr_reader :kernel, :order
  
  def initialize kernel
    @kernel = kernel
    @order = kernel.size - 1
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
  
  def freq_response sample_rate, use_db = true
    input = [0.0] + @kernel # make the size even
    output = DFT.forward_dft input, true  # set skip_second_half to true to ignore second half of output (mirror image)

    # calculate magnitudes from complex values
    output = output.map {|x| x.magnitude }
    
    if use_db
      output = output.map {|x| Gain::linear_to_db x }
    end
    
    response = {}
    output.each_index do |n|
      frequency = (sample_rate * n) / (output.size * 2)
      response[frequency] = output[n]
    end
    
    ## amplitude = 2 * f[j] / size
    #output = output.map {|x| 2 * x / output.size }
    
    return response
  end
  
  def plot_freq_response sample_rate, use_db = true
    response = freq_response sample_rate, use_db
    
    Gnuplot.open do |gp|
      Gnuplot::Plot.new(gp) do |plot|
        plot.title  "Freq response of #{@order}-order FIR filter"
        plot.xlabel "frequency (Hz)"
        plot.ylabel "DFT magnitude response#{use_db ? " (dB)" : ""}"
        plot.logscale 'x'
      
        plot.data = [            
          Gnuplot::DataSet.new( [ response.keys, response.values ] ) { |ds|
            ds.with = "lines"
            ds.title = "magnitude response#{use_db ? " (dB)" : ""}"
            ds.linewidth = 1
          },
        ]
      end
    end

  end
end
end
