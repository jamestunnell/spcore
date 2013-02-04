require 'pry'
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SPCore::Gain do
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
        SPCore::Gain::db_to_linear(conversion[:db]).should be_within(0.01).of(conversion[:linear])
      end
    end

    it 'should prove to be the inverse of .db_to_linear' do
      20.times do
        x = SPCore::Interpolation.linear(0.0, -SPCore::Gain::MAX_DB_ABS, 1.0, SPCore::Gain::MAX_DB_ABS, rand)
        y = SPCore::Gain::db_to_linear(x)
        z = SPCore::Gain::linear_to_db(y)
        ((z - x).abs / x).should be_within(1e-5).of(0.0)
      end
    end
  end
  
  describe '.linear_to_db' do
    it 'should convert linear unit to decibel (logarithmic)' do
      @conversions.each do |conversion|
        SPCore::Gain::linear_to_db(conversion[:linear]).should be_within(0.01).of(conversion[:db])
      end
    end

    it 'should prove to be the inverse of .db_to_linear' do
      20.times do
        max_gain_linear = SPCore::Gain::db_to_linear(SPCore::Gain::MAX_DB_ABS)
        min_gain_linear = SPCore::Gain::db_to_linear(-SPCore::Gain::MAX_DB_ABS)
        x = SPCore::Interpolation.linear(0.0, min_gain_linear, 1.0, max_gain_linear, rand)
        y = SPCore::Gain::linear_to_db(x)
        z = SPCore::Gain::db_to_linear(y)
        ((z - x).abs / x).should be_within(1e-5).of(0.0)
      end
    end
  end
end
