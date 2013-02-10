require 'pry'
module SPCore

# Base windowed sinc filter. Implements lowpass and highpass. A bandpass
# and bandstop filter would be implemented using two of these.
#
# Theoretical source: http://www.labbookpages.co.uk/audio/firWindowing.html
#
# @author James Tunnell
#
class SincFilter
  include Hashmake::HashMakeable
  
  ARG_SPECS = [
    Hashmake::ArgSpec.new(:key => :order, :reqd => true, :type => Fixnum, :validator => ->(a){ a % 2 == 0 } ),
    Hashmake::ArgSpec.new(:key => :sample_rate, :reqd => true, :type => Numeric, :validator => ->(a){ a > 0.0 } ),
    Hashmake::ArgSpec.new(:key => :cutoff_freq, :reqd => true, :type => Numeric, :validator => ->(a){ a > 0.0 } ),
    Hashmake::ArgSpec.new(:key => :window_class, :reqd => false, :type => Class, :default => BlackmanWindow ),
  ]
  
  attr_reader :lowpass_fir, :highpass_fir
  
  # Given a filter order, cutoff frequency, sample rate, and window class,
  # develop a FIR filter kernel that can be used for lowpass filtering.
  def initialize args
    hash_make SincFilter::ARG_SPECS, args
    
    raise ArgumentError, "cutoff_freq is greater than 0.5 * sample_rate" if @cutoff_freq > (@sample_rate / 2)
    
    size = @order + 1
    transition_freq = @cutoff_freq / @sample_rate
    b = TWO_PI * transition_freq
    
    # make FIR filter kernels for lowpass and highpass
    
    lowpass_kernel = Array.new(size)
    highpass_kernel = Array.new(size)
    window = @window_class.new(size)
    
    for n in 0...(@order / 2)
      c = n - (@order / 2)
      y = Math::sin(b * c) / (Math::PI * (c))
      lowpass_kernel[size - 1 - n] = lowpass_kernel[n] = y * window.data[n]
      highpass_kernel[size - 1 - n] = highpass_kernel[n] = -lowpass_kernel[n]
    end
    lowpass_kernel[@order / 2] = 2 * transition_freq * window.data[@order / 2]
    highpass_kernel[@order / 2] = (1 - 2 * transition_freq) * window.data[@order / 2]
    
    #highpass_kernel = lowpass_kernel.map {|x| -x}
    #highpass_kernel[@order / 2] = (1 - (2 * transition_freq)) * window.data[@order / 2]
    
    @lowpass_fir = FIR.new lowpass_kernel
    @highpass_fir = FIR.new highpass_kernel
    
    #binding.pry
    #
    #ns = []
    #@lowpass_fir.kernel.each_index do |n|
    #  ns << n
    #end
    #
    #Gnuplot.open do |gp|
    #  Gnuplot::Plot.new(gp) do |plot|
    #    plot.title  "filter kernels"
    #    plot.xlabel "n"
    #    plot.ylabel "y(n)"
    #    #plot.logscale 'x'
    #  
    #    plot.data = [            
    #      Gnuplot::DataSet.new( [ ns, @lowpass_fir.kernel ] ) { |ds|
    #        ds.with = "lines"
    #        ds.title = "DFT magnitude response"
    #        ds.linewidth = 1
    #      },
    #      Gnuplot::DataSet.new( [ ns, @highpass_fir.kernel ] ) { |ds|
    #        ds.with = "lines"
    #        ds.title = "DFT magnitude response"
    #        ds.linewidth = 1
    #      },
    #    ]
    #  end
    #end
  end
  
  def lowpass input
    return @lowpass_fir.convolve input
  end
  
  def highpass input
    return @highpass_fir.convolve input
  end
end


end
