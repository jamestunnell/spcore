require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'pry'
require 'gnuplot'

describe SPCore::DFT do
  context '.forward' do
    it 'should produce identical output when skip_second_half is set to true' do
      input = SignalGenerator.new(:sample_rate => 400.0, :size => 128).make_noise.data
      
      output1 = DFT.forward input
      output1 = output1[0, output1.size / 2]
      
      output2 = DFT.forward input, true
      
      output1.should eq(output2)
    end
  
    it 'should produce a freq magnitude response peak that is within 10 percent of the test freq' do
      min_dft_size = 128
      sample_rate = 400.0
      
      test_freqs = [
        10.0,
        20.0,
        40.0,
        80.0,
      ]
      
      test_freqs.each do |freq|
        osc = Oscillator.new(:frequency => freq, :sample_rate => sample_rate)
  
        input_size = (5 * sample_rate / test_freqs.min).to_i
        if input_size < min_dft_size
          input_size = min_dft_size
        end
  
        input = Array.new(input_size)
        window = BlackmanHarrisWindow.new(input_size)
        
        input_size.times do |i|
          input[i] = osc.sample * window.data[i]
        end
        
        output = DFT.forward input, true  # skip_second_half is set to true
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
        #    plot.title  "#{input_size}-point DFT on #{freq} Hz sine wave signal"
        #    plot.xlabel "frequency (Hz)"
        #    plot.ylabel "DFT magnitude response"
        #    #plot.logscale 'x'
        #  
        #    plot.data = [            
        #      Gnuplot::DataSet.new( [ frequencies, output ] ) { |ds|
        #        ds.with = "lines"
        #        ds.title = "DFT magnitude response"
        #        ds.linewidth = 1
        #      },
        #    ]
        #  end
        #end
      end
    end
  end
  
  context '.inverse' do
  
    it 'should produce a near-identical signal to the original sent into the forward DFT (with energy that is within 10 percent error of original signal)' do
      dft_size = 64
      sample_rate = 400.0
      
      test_freqs = [
        20.0,
        40.0,
      ]
      
      test_freqs.each do |freq|
        input = SignalGenerator.new(:sample_rate => sample_rate, :size => dft_size).make_signal([freq])
        input *= BlackmanHarrisWindow.new(dft_size).data
        
        output = DFT.forward input.data
        input2 = DFT.inverse output
        
        energy1 = input.energy
        energy2 = input2.inject(0.0){|sum,x| sum + (x * x)}
  
        percent_err = (energy2 - energy1).abs / energy1
        percent_err.should be_within(0.10).of(0.0)
        
        #Plotter.new(
        #  :title => "#{dft_size}-point DFT on #{freq} Hz sine wave signal",
        #  :xlabel => "frequency (Hz)",
        #  :ylabel => "magnitude response",
        #).plot_1d("input1" => input.data, "input2" => input2)
      end
    end
  end

end
