require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'pry'
require 'gnuplot'

describe SPCore::DFT do
  context '.forward' do
  
    it 'should produce a freq magnitude response peak that is within 10 percent of the test freq' do
      dft_size = 64
      sample_rate = 400
      
      test_freqs = [
        20.0,
        40.0,
      ]
      
      test_freqs.each do |freq|
        signal = SignalGenerator.new(:sample_rate => sample_rate, :size => dft_size).make_signal([freq])
        signal *= BlackmanHarrisWindow.new(dft_size).data
        
        output = DFT.forward signal.data
        output = output[0...(output.size / 2)]  # skip second half
        output = output.map { |x| x.magnitude } # map complex values to magnitude
  
        freq_magnitudes = {}
        output.each_index do |i|
          f = (sample_rate * i) / dft_size
          freq_magnitudes[f] = output[i]
        end
        
        max_freq = freq_magnitudes.max_by {|f,mag| mag}[0]
        percent_err = (max_freq - freq).abs / freq
        percent_err.should be_within(0.10).of(0.0)
      end
    end
  end
  
  context '.inverse' do
  
    it 'should produce a near-identical signal to the original sent into the forward DFT (with energy that is within 10 percent error of original signal)' do
      dft_size = 32
      sample_rate = 400
      
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
