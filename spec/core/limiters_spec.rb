require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SPCore::Limiters do
  describe '.make_no_limiter' do
    it 'should make a lambda that does not limit values' do
      limiter = SPCore::Limiters.make_no_limiter
      limiter.call(Float::MAX).should eq(Float::MAX)
      limiter.call(-Float::MAX).should eq(-Float::MAX)
      limiter.call(Float::MIN).should eq(Float::MIN)
    end
  end
  
  describe '.make_lower_limiter' do
    it 'should make a lambda that limits values to be above the limit value' do
      limiter = SPCore::Limiters.make_lower_limiter 5.0
      limiter.call(4.5).should eq(5.0)
      limiter.call(5.5).should eq(5.5)
    end
  end

  describe 'make_upper_limiter' do
    it 'should make a lambda that limits values to be above the limit value' do
      limiter = SPCore::Limiters.make_upper_limiter 5.0
      limiter.call(5.5).should eq(5.0)
      limiter.call(4.5).should eq(4.5)
    end
  end

  describe '.make_range_limiter' do
    it 'should make a lambda that limits values to be between the limit range' do
      limiter = SPCore::Limiters.make_range_limiter(2.5..5.0)
      limiter.call(1.5).should eq(2.5)
      limiter.call(5.5).should eq(5.0)
      limiter.call(3.0).should eq(3.0)
    end
  end

end
