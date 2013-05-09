require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SPCore::Signal do
  describe '#derivative' do
    before :all do
      sample_rate = 200
      sample_period = 1.0 / sample_rate
      sample_count = sample_rate
      
      range = -Math::PI..Math::PI
      delta = (range.max - range.min) / sample_count
      
      sin = []
      cos = []
      
      range.step(delta) do |x|
        sin << Math::sin(x)
        cos << (Math::PI * 2 * Math::cos(x))
      end
      
      @sin = SPCore::Signal.new(:sample_rate => sample_count, :data => sin)
      @expected = SPCore::Signal.new(:sample_rate => sample_count, :data => cos)
      @actual = @sin.derivative(true)
    end
    
    it 'should produce a signal of same size' do
      @actual.size.should eq @expected.size
    end
    
    it 'should produce a signal matching the 1st derivative' do
      @actual.data.each_index do |i|
        @actual[i].should be_within(0.1).of(@expected[i])
      end
    end
  end
  
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