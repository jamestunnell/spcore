require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SPCore::Calculus do
  before :all do
    sample_rate = 200
    @sample_period = 1.0 / sample_rate
    sample_count = sample_rate
    
    range = -Math::PI..Math::PI
    delta = (range.max - range.min) / sample_count
    
    @sin = []
    @cos = []
    
    range.step(delta) do |x|
      @sin << Math::sin(x)
      @cos << (Math::PI * 2 * Math::cos(x))
    end
  end
  
  describe '.derivative' do
    before :all do
      @expected = @cos
      @actual = Calculus.derivative @sin, @sample_period
    end
    
    it 'should produce a signal of same size' do
      @actual.size.should eq @expected.size
    end
    
    it 'should produce a signal matching the 1st derivative' do
      @actual.each_index do |i|
        @actual[i].should be_within(0.1).of(@expected[i])
      end
    end
  end

  describe '.integral' do
    before :all do
      @expected = @sin
      @actual = Calculus.integral @cos, @sample_period
    end
    
    it 'should produce a signal of same size' do
      @actual.size.should eq @expected.size
    end
    
    it 'should produce a signal matching the 1st derivative' do
      @actual.each_index do |i|
        @actual[i].should be_within(0.1).of(@expected[i])
      end
    end
  end
end