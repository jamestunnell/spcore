require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SPCore::Signal do
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