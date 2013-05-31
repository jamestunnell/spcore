require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SPCore::Signal do
  describe '#duration' do
    it 'should produce duration in seconds, according to sample_rate' do
      sample_rate = 2000
      [5,50,100,1500].each do |count|
        zeros = Array.new(count, 0)
        signal = SPCore::Signal.new(:data => zeros, :sample_rate => sample_rate)
        expected_duration = count.to_f / sample_rate
        signal.duration.should eq expected_duration
      end      
    end
  end
    
  describe '#normalize' do
    before :all do
      generator = SignalGenerator.new(:sample_rate => 2000, :size => 256)
      @signal = generator.make_signal([40.0, 160.0]).multiply(HannWindow.new(256).data)
      @max = @signal.data.max
    end
    
    it 'should be able to normalize to a level lower than peak value' do
      normalized = @signal.normalize(@max * 0.75)
      normalized.data.max.should eq(@max * 0.75)
    end
    
    it 'should be able to normalize to a level higher than peak value' do
      normalized = @signal.normalize(@max * 1.5)
      normalized.data.max.should eq(@max * 1.5)
    end

    it 'should be able to normalize to a level equal to peak value' do
      normalized = @signal.normalize(@max)
      normalized.data.max.should eq(@max)
    end
  end
  
  #describe '#fundamental' do
  #  context 'harmonic series present' do
  #    it 'should find the fundamental component of a harmonic series' do
  #      cases = {
  #        [40.0, 80.0, 120.0, 160.0] => 40.0,
  #      }
  #      
  #      cases.each do |freqs, fundamental|
  #        generator = SignalGenerator.new(:sample_rate => 2000, :size => 256)
  #        signal = generator.make_signal(freqs)
  #        signal.fundamental.should be_within(5.0).of(fundamental)
  #      end
  #    end
  #  end
  #  
  #  context 'no harmonic series preset' do
  #    it 'should return the strongest peak frequency' do
  #      ideal_peaks = [40.0, 160.0, 250.0]
  #      generator = SignalGenerator.new(:sample_rate => 2000, :size => 256)
  #      signal = generator.make_signal(ideal_peaks)
  #      signal.fundamental.should be_within(5.0).of(40.0)
  #    end
  #  end
  #end
  #
  #describe '#freq_peaks' do
  #  it 'should find the peak frequency components' do
  #    ideal_peaks = [40.0, 160.0, 250.0]
  #    generator = SignalGenerator.new(:sample_rate => 2000, :size => 256)
  #    signal = generator.make_signal(ideal_peaks)
  #    actual_peaks = signal.freq_peaks(5.0, 4, 2.0)
  #    
  #    ideal_peaks.count.times do |i|
  #      actual_peaks[i].should be_within(5.0).of(ideal_peaks[i])
  #    end
  #  end
  #end

  describe '#remove_frequencies' do
    before :each do
      generator = SignalGenerator.new(:sample_rate => 2000, :size => 256)
      @original = generator.make_signal([40.0, 160.0])
      @ideal_modified = generator.make_signal([160.0])
    end
    
    it 'should produce the expected modified signal (with almost identical energy and RMS)' do
      modified = @original.remove_frequencies(0.0..80.0)
      
      begin
        actual = modified.energy
        ideal = @ideal_modified.energy
        error = (actual - ideal).abs / ideal
        error.should be_within(0.05).of(0.0)
      end

      begin
        actual = modified.rms
        ideal = @ideal_modified.rms
        error = (actual - ideal).abs / ideal
        error.should be_within(0.05).of(0.0)
      end
      
      #Plotter.new().plot_signals(
      #  #"original" => @original,
      #  "ideal modified" => @ideal_modified,
      #  "actual modified" => modified
      #)
    end
  end

  describe '#keep_frequencies' do
    before :each do
      generator = SignalGenerator.new(:sample_rate => 2000, :size => 256)
      @original = generator.make_signal([40.0, 160.0])
      @ideal_modified = generator.make_signal([160.0])
    end
    
    it 'should produce the expected modified signal (with almost identical energy and RMS)' do
      modified = @original.keep_frequencies(80.0..240.0)
      
      begin
        actual = modified.energy
        ideal = @ideal_modified.energy
        error = (actual - ideal).abs / ideal
        error.should be_within(0.05).of(0.0)
      end

      begin
        actual = modified.rms
        ideal = @ideal_modified.rms
        error = (actual - ideal).abs / ideal
        error.should be_within(0.05).of(0.0)
      end
      
      #Plotter.new().plot_signals(
      #  #"original" => @original,
      #  "ideal modified" => @ideal_modified,
      #  "actual modified" => modified
      #)
    end
  end
end
