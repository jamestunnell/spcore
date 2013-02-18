require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'pry'
require 'gnuplot'

describe SPCore::FFT do
  context '.forward' do
    #it 'should produce identical output when skip_second_half is set to true' do
    #  input = SignalGenerator.new(:sample_rate => 400.0, :size => 128).make_noise.data
    #  
    #  output1 = DFT.forward_dft input
    #  output1 = output1[0, output1.size / 2]
    #  
    #  output2 = DFT.forward_dft input, true
    #  
    #  output1.should eq(output2)
    #end
  
    it 'should produce a freq magnitude response peak that is within 10 percent of the test freq' do
      fft_size = 512
      sample_rate = 400.0
      
      test_freqs = [
        10.0,
        20.0,
        40.0,
        80.0,
      ]
      
      test_freqs.each do |freq|
        osc = Oscillator.new(:frequency => freq, :sample_rate => sample_rate)
  
        input_size = fft_size
  
        input = Array.new(input_size)
        window = BlackmanHarrisWindow.new(input_size)
        
        input_size.times do |i|
          input[i] = osc.sample * window.data[i]
        end
        
        output = FFT.forward input
        output = output[0...(output.size / 2)]
        output = output.map { |x| x.magnitude } # map complex values to magnitude
  
        frequencies = Array.new(output.size)
        output.each_index do |n|
          frequencies[n] = (sample_rate * n) / (output.size * 2)
        end
        
        max_freq = frequencies.first
        max_magn = output.first
        (input_size / 2).times do |n|
          if output[n] > max_magn
            max_magn = output[n]
            max_freq = frequencies[n]
          end
        end
        percent_err = (max_freq - freq).abs / freq
        percent_err.should be_within(0.10).of(0.0)
  
        #Gnuplot.open do |gp|
        #  Gnuplot::Plot.new(gp) do |plot|
        #    plot.title  "#{input_size}-point FFT on #{freq} Hz sine wave signal"
        #    plot.xlabel "frequency (Hz)"
        #    plot.ylabel "magnitude response"
        #    #plot.logscale 'x'
        #  
        #    plot.data = [            
        #      Gnuplot::DataSet.new( [ frequencies, output ] ) { |ds|
        #        ds.with = "lines"
        #        ds.title = "magnitude response"
        #        ds.linewidth = 1
        #      },
        #    ]
        #  end
        #end
      end
    end
  end
  
end
