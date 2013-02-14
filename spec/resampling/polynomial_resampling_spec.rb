require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'gnuplot'

describe SPCore::PolynomialResampling do

  context '.upsample' do
    it 'should produce output signal with the same max frequency (put through forward DFT)' do
      sample_rate = 400.0
      test_freq = 10.0
      size = (sample_rate * 5.0 / test_freq).to_i
      upsample_factor = 2.5
      
      generator = SignalGenerator.new :sample_rate => sample_rate, :size => size
      signal = generator.make_signal [test_freq]
      input = signal
      
      output = Resampling.upsample_polynomial input, sample_rate, upsample_factor
      output.size.should eq(size * upsample_factor)
      
      dft1 = DFT.forward_dft input, true
      dft1 = dft1.map{ |x| x.magnitude }
      dft1_max_i = dft1.index(dft1.max)
      dft1_max_freq = (sample_rate * dft1_max_i) / (dft1.size * 2)
      
      dft2 = DFT.forward_dft output, true
      dft2 = dft2.map{ |x| x.magnitude }
      dft2_max_i = dft2.index(dft2.max)
      dft2_max_freq = (sample_rate * upsample_factor * dft2_max_i) / (dft2.size * 2)
      
      percent_error = (dft1_max_freq - dft2_max_freq).abs / dft1_max_freq
      percent_error.should be_within(0.1).of(0.0)
      
      #input_indices = []
      #input.each_index do |i|
      #  input_indices[i] = i
      #end
      #
      #output_indices = []
      #output.each_index do |i|
      #  output_indices[i] = i
      #end
      #
      #Gnuplot.open do |gp|
      #  Gnuplot::Plot.new(gp) do |plot|
      #    plot.title  "Upsampling by #{upsample_factor}"
      #    plot.xlabel "sample numbers"
      #    plot.ylabel "samples"
      #    
      #    plot.data = [
      #      Gnuplot::DataSet.new( [ input_indices, input ] ) { |ds|
      #        ds.with = "lines"
      #        ds.title = "original input"
      #        ds.linewidth = 1
      #      },
      #      Gnuplot::DataSet.new( [ output_indices, output ] ) { |ds|
      #        ds.with = "lines"
      #        ds.title = "resampled input"
      #        ds.linewidth = 1
      #      }
      #    ]
      #  end
      #end
      
    end
  end
  
end
