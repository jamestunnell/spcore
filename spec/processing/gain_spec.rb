require 'pry'
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SigProc::Gain do
  before :all do
    @conversions = [
      { :linear => Math::sqrt(2.0), :db => 3.01 },
      { :linear => 2.0, :db => 6.02 },
      { :linear => 4.0, :db => 12.04 },
    ]
  end
  
  describe '.db_to_linear' do
    it 'should convert decibel (logarithmic) unit to linear' do
      @conversions.each do |conversion|
        SigProc::Gain::db_to_linear(conversion[:db]).should be_within(0.01).of(conversion[:linear])
      end
    end

    it 'should prove to be the inverse of .db_to_linear' do
      20.times do
        x = SigProc::Interpolation.linear(0.0, -SigProc::Gain::MAX_DB_ABS, 1.0, SigProc::Gain::MAX_DB_ABS, rand)
        y = SigProc::Gain::db_to_linear(x)
        z = SigProc::Gain::linear_to_db(y)
        ((z - x).abs / x).should be_within(1e-5).of(0.0)
      end
    end
  end
  
  describe '.linear_to_db' do
    it 'should convert linear unit to decibel (logarithmic)' do
      @conversions.each do |conversion|
        SigProc::Gain::linear_to_db(conversion[:linear]).should be_within(0.01).of(conversion[:db])
      end
    end

    it 'should prove to be the inverse of .db_to_linear' do
      20.times do
        max_gain_linear = SigProc::Gain::db_to_linear(SigProc::Gain::MAX_DB_ABS)
        min_gain_linear = SigProc::Gain::db_to_linear(-SigProc::Gain::MAX_DB_ABS)
        x = SigProc::Interpolation.linear(0.0, min_gain_linear, 1.0, max_gain_linear, rand)
        y = SigProc::Gain::linear_to_db(x)
        z = SigProc::Gain::db_to_linear(y)
        ((z - x).abs / x).should be_within(1e-5).of(0.0)
      end
    end
  end
end
