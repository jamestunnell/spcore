require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'gnuplot'

describe SPCore::PolynomialResampling do

  context '.upsample' do
    it 'should produce output signal with the same max frequency (put through forward DFT)' do
      sample_rate = 400
      test_freq = 10.0
      size = (sample_rate * 5.0 / test_freq).to_i
      upsample_factor = 2.5
      
      generator = SignalGenerator.new :sample_rate => sample_rate, :size => size
      signal1 = generator.make_signal [test_freq]
      signal2 = signal1.clone.upsample_polynomial upsample_factor
       
      #plotter = Plotter.new(:title => "Polynomial upsampling by #{upsample_factor}")
      #plotter.plot_1d("original signal" => signal1.data, "upsampled signal" => signal2.data)
      
      signal2.size.should eq(signal1.size * upsample_factor)
      
      max_freq1 = signal1.freq_magnitudes.max_by{|freq, mag| mag }[0]
      max_freq2 = signal2.freq_magnitudes.max_by{|freq, mag| mag }[0]
      
      percent_error = (max_freq1 - max_freq2).abs / max_freq1
      percent_error.should be_within(0.1).of(0.0)
    end
  end
  
end
