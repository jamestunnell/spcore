require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SigProc::Limit do
  describe 'no limit' do
    before :all do
      @limit = SigProc::Limit.new SigProc::Limit::TYPE_NONE, []
    end
    
    it 'should not limit values' do
      @limit.limit(Float::MAX).should eq(Float::MAX)
      @limit.limit(-Float::MAX).should eq(-Float::MAX)
      @limit.limit(Float::MIN).should eq(Float::MIN)
    end
  end
  
  describe 'lower limit' do
    before :all do
      @limit = SigProc::Limit.new SigProc::Limit::TYPE_LOWER, [5.0]
    end
    
    it 'should limit values to be above the first limit value' do
      @limit.limit(4.5).should eq(5.0)
      @limit.limit(5.5).should eq(5.5)
    end
  end

  describe 'upper limit' do
    before :all do
      @limit = SigProc::Limit.new SigProc::Limit::TYPE_UPPER, [5.0]
    end
    
    it 'should limit values to be below the first limit value' do
      @limit.limit(5.5).should eq(5.0)
      @limit.limit(4.5).should eq(4.5)
    end
  end

  describe 'range limit' do
    before :all do
      @limit = SigProc::Limit.new SigProc::Limit::TYPE_RANGE, [2.5, 5.0]
    end
    
    it 'should limit values between the two limit values' do
      @limit.limit(1.5).should eq(2.5)
      @limit.limit(5.5).should eq(5.0)
      @limit.limit(3.0).should eq(3.0)
    end
  end

  describe 'enum limit' do
    before :all do
      @limit = SigProc::Limit.new SigProc::Limit::TYPE_ENUM, [0.0, 2.5, 5.0]
    end
    
    it 'should limit values to those enumerated in the limit values' do
      @limit.limit(0.5).should eq(0.0)
      @limit.limit(1.25).should eq(0.0)
      @limit.limit(1.75).should eq(2.5)
      @limit.limit(2.5).should eq(2.5)
      @limit.limit(2.6).should eq(2.5)
      @limit.limit(4.5).should eq(5.0)
    end
  end

end
