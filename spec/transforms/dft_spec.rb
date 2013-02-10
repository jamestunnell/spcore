require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'pry'

describe SPCore::DFT do
  context '.forward_dft' do

    it 'should produce a freq magnitude response peak that is within 10 percent of the test freq' do
      min_dft_size = 256
      sample_rate = 4000.0
      
      test_freqs = [
        100.0,
        200.0,
        400.0,
        800.0,
        1600.0
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
        
        output = DFT.forward_dft input
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
  
        Gnuplot.open do |gp|
          Gnuplot::Plot.new(gp) do |plot|
            plot.title  "#{input_size}-point DFT on #{freq} Hz sine wave signal"
            plot.xlabel "frequency (Hz)"
            plot.ylabel "DFT magnitude response"
            #plot.logscale 'x'
          
            plot.data = [            
              Gnuplot::DataSet.new( [ frequencies, output ] ) { |ds|
                ds.with = "lines"
                ds.title = "DFT magnitude response"
                ds.linewidth = 1
              },
            ]
          end
        end
      end
    end
  end
end
