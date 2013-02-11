module SPCore
class FIR
  
  attr_reader :kernel, :order
  
  def initialize kernel
    @kernel = kernel
    @order = kernel.size - 1
  end
  
  def convolve input
    raise ArgumentError, "input.size #{input.size} is not greater than filter kernel size #{@kernel.size}" unless input.size > @kernel.size
    
    output = Array.new(input.size, 0.0)

    # first @lowpass_kernel.size entries are 0
    for j in @kernel.size...input.size
      # convolve the input with the filter kernel
      for i in 0...@kernel.size
        output[j] += (input[j-i] * @kernel[i])
      end
    end
    
    return output
  end
  
  def freq_response sample_rate, use_db = true
    input = [0.0] + @kernel # make the size even

    #binding.pry
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
