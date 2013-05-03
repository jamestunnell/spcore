require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'gnuplot'

describe SPCore::HybridResampling do

  context '.resample' do
    it 'should produce output signal with the same max frequency (put through forward FFT)' do
      sample_rate = 400
      test_freq = 10.0
      size = 64
      upsample_factor = 10
      downsample_factor = 4
      order = (sample_rate / test_freq).to_i
      
      signal1 = SignalGenerator.new(:sample_rate => sample_rate, :size => size).make_signal [test_freq]
      signal1 *= BlackmanWindow.new(size).data
      signal2 = signal1.clone.resample_hybrid upsample_factor, downsample_factor, order
      
      #plotter = Plotter.new(:title => "Discrete resampling, up by #{upsample_factor}, down by #{downsample_factor}")
      #plotter.plot_1d("original signal" => signal1.data, "resampled signal" => signal2.data)

      signal2.size.should eq(signal1.size * upsample_factor / downsample_factor)
      
      max_freq1 = signal1.freq_magnitudes.max_by{|freq, mag| mag }[0]
      max_freq2 = signal2.freq_magnitudes.max_by{|freq, mag| mag }[0]
      
      percent_error = (max_freq1 - max_freq2).abs / max_freq1
      percent_error.should be_within(0.1).of(0.0)
    end
  end  
end
