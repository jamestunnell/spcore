require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'pry'
require 'gnuplot'

describe SPCore::FFT do
  context '.forward' do
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
  
        magn_response = {}
        output.each_index do |n|
          f = (sample_rate * n) / (output.size * 2)
          magn_response[f] = output[n]
        end
        
        max_freq = magn_response.max_by {|f,magn| magn }[0]
        percent_err = (max_freq - freq).abs / freq
        percent_err.should be_within(0.10).of(0.0)
        
        #Plotter.new(
        #  :title => "#{input_size}-point FFT on #{freq} Hz sine wave signal",
        #  :xlabel => "frequency (Hz)",
        #  :ylabel => "magnitude response",
        #).plot_2d("magnitude response" => magn_response)
      end
    end
  end

  context '.inverse' do

    it 'should produce a near-identical signal to the original sent into the forward DFT (with energy that is within 10 percent error of original signal)' do
      fft_size = 128
      sample_rate = 400.0
      
      test_freqs = [
        20.0,
        40.0,
      ]
      
      test_freqs.each do |freq|
        input = SignalGenerator.new(:sample_rate => sample_rate, :size => fft_size).make_signal([freq])
        input *= BlackmanHarrisWindow.new(fft_size).data
        
        output = FFT.forward input.data
        input2 = FFT.inverse output
        
        energy1 = input.energy
        energy2 = input2.inject(0.0){|sum,x| sum + (x * x)}
  
        percent_err = (energy2 - energy1).abs / energy1
        percent_err.should be_within(0.10).of(0.0)

        #Plotter.new(
        #  :title => "#{fft_size}-point FFT on #{freq} Hz sine wave signal",
        #  :xlabel => "frequency (Hz)",
        #  :ylabel => "magnitude response",
        #).plot_1d("input1" => input.data, "input2" => input2)
      end
    end
  end
  
end
