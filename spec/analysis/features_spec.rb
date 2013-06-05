require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SPCore::Features do
  context '.minima' do
    it 'should return points where local and global minima occur' do
      cases = {
        [3.8, 3.0, 2.9, 2.95, 3.6, 3.4, 2.8, 2.3, 2.1, 2.0, 2.5] => { 2 => 2.9, 9 => 2.0 },
        [3.2, 3.5, 2.9, 2.7, 2.8, 2.7, 2.5, 2.2, 2.4, 2.3, 2.0] => { 3 => 2.7, 7 => 2.2, 10 => 2.0 },
      }
        
      cases.each do |samples, minima|
        Features.minima(samples).should eq minima
      end
    end
  end
  
  context '.maxima' do
    it 'should return points where local and global maxima occur' do
      cases = {
        [3.8, 3.0, 2.9, 2.95, 3.6, 3.4, 2.8, 2.3, 2.1, 2.0, 2.5] => { 0 => 3.8, 4 => 3.6 },
        [3.2, 3.5, 2.9, 2.7, 2.8, 2.7, 2.5, 2.2, 2.4, 2.3, 2.0] => { 1 => 3.5, 4 => 2.8, 8 => 2.4},
      }
        
      cases.each do |samples, maxima|
        Features.maxima(samples).should eq maxima
      end
    end
  end
  
  context '.extrema' do
    it 'should return points where local and global extrema occur' do
      cases = {
        [3.8, 3.0, 2.9, 2.95, 3.6, 3.4, 2.8, 2.3, 2.1, 2.0, 2.5] => { 0 => 3.8, 2 => 2.9, 4 => 3.6, 9 => 2.0},
        [3.2, 3.5, 2.9, 2.7, 2.8, 2.7, 2.5, 2.2, 2.4, 2.3, 2.0] => { 1 => 3.5, 3 => 2.7, 4 => 2.8, 7 => 2.2, 8 => 2.4, 10 => 2.0},
      }
        
      cases.each do |samples, extrema|
        Features.extrema(samples).should eq extrema
      end
    end
  end
  
  describe '.top_n' do
    it 'should return the n greatest of the given values' do
      cases = {
        [[1,2,3,4,5,6],2] => [5,6],
        [[13,2,32,42,75,6],4] => [13,32,42,75],
        [[-11,21,-4],1] => [21],
        [[-11,21,-4, -14],2] => [-4,21],
      }
      
      cases.each do |inputs, expected_output|
        Features.top_n(inputs[0], inputs[1]).should eq expected_output
      end
    end
  end
  
  describe '.envelope' do
    before :all do
      sample_rate = 1000
      sample_count = 512 * 2
      generator = SignalGenerator.new(:size => sample_count, :sample_rate => sample_rate)
      
      @modulation_signal = generator.make_signal [4.0], :amplitude => 0.1
      @modulation_signal.multiply! BlackmanWindow.new(sample_count).data
  
      @base_signal = generator.make_signal [64.0]
      @base_signal.multiply! @modulation_signal
    end
  
    it 'should produce an output that follows the amplitude of the input' do
      envelope = @base_signal.envelope
      check_envelope(envelope)
    end
    
    def check_envelope envelope
      #signals = {
      #  "signal" => @base_signal,
      #  "modulation (abs)" => @modulation_signal.abs,
      #  "envelope" => envelope,
      #}
      #
      #Plotter.new(
      #  :title => "signal and envelope",
      #  :xlabel => "sample",
      #  :ylabel => "values",
      #).plot_signals(signals)
      
      #Plotter.new().plot_2d("envelop freq magnitudes" => envelope.freq_magnitudes)
      
      begin
        ideal = @modulation_signal.energy
        actual = envelope.energy
        error = (ideal - actual).abs / ideal
        error.should be_within(0.1).of(0.0)
      end
      
      begin
        ideal = @modulation_signal.rms
        actual = envelope.rms
        error = (ideal - actual).abs / ideal
        error.should be_within(0.1).of(0.0)
      end
    end
  end
end
