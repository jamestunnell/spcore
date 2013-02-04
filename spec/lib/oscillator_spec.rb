require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'gnuplot'
require 'pry'

describe SPCore::Oscillator do
  #it 'should look like a ...' do
  #  sample_rate = 44000.0
  #  test_freq = 100.0
  #  osc = SPCore::Oscillator.new :sample_rate => sample_rate, :frequency => test_freq, :wave_type => SPCore::Oscillator::WAVE_SQUARE
  #  N = (5 * sample_rate / test_freq).to_i
  #  period = 1.0 / N
  #  
  #  x, y = [], []
  #  N.times do |n|
  #    x << (n * period)
  #    y << osc.sample
  #  end
  #
  #  Gnuplot.open do |gp|
  #    Gnuplot::Plot.new(gp) do |plot|
  #      plot.title  "#{osc.frequency} Hz #{osc.wave_type} oscillator"
  #      plot.xlabel "time (x)"
  #      plot.ylabel "f(x)"
  #    
  #      plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
  #        ds.with = "linespoints"
  #        #ds.linewidth = 4
  #      end
  #    end
  #  end
  #  
  #end
  
  before :each do
    @sample_rate = 40000.0
    @freqs = [ 20.0, 200.0, 400.0 ]
  end
  
  describe '#triangle' do
    it "should produce increasing samples during first half-period, and decreasing samples during the second half-period" do
      @freqs.each do |freq|
        wave = SPCore::Oscillator.new(
          :sample_rate => @sample_rate,
          :frequency => freq,
          :wave_type => SPCore::Oscillator::WAVE_TRIANGLE
        )
        
        samples_in_half_period = @sample_rate / (2.0 * freq)
        
        prev = wave.sample
        prev.should eq(-1)
        
        (samples_in_half_period - 1).to_i.times do
          current = wave.sample
          current.should be > prev
          prev = current
        end
  
        prev = wave.sample
        prev.should be_within(0.01).of(1)
        
        (samples_in_half_period - 1).to_i.times do
          current = wave.sample
          current.should be < prev
          prev = current
        end
        
        wave.sample.should be_within(0.01).of(-1)
      end
    end
  end

  describe '#square' do
      it "should produce 1 during first half-period, and -1 during second half-period" do
      @freqs.each do |freq|
        wave = SPCore::Oscillator.new(
          :sample_rate => @sample_rate,
          :frequency => freq,
          :wave_type => SPCore::Oscillator::WAVE_SQUARE
        )
    
        samples_in_half_period = @sample_rate / (2.0 * freq)
        fails = 0
        
        samples_in_half_period.to_i.times do
          if wave.sample != 1.0 then fails += 1 end
        end
        
        samples_in_half_period.to_i.times do
          if wave.sample != -1.0 then fails += 1 end
        end
        
        (fails <= 2).should be_true
      end
    end
  end

  describe '#sawtooth' do
    it "should produce increasing samples" do

      @freqs.each do |freq|
        wave = SPCore::Oscillator.new(
          :sample_rate => @sample_rate,
          :frequency => freq,
          :wave_type => SPCore::Oscillator::WAVE_SAWTOOTH
        )

        samples_in_period = (@sample_rate / freq).to_i
        fails = 0
        
        prev = wave.sample
        (samples_in_period - 1).times do
          current = wave.sample
          if current < prev
            fails += 1
          end
          prev = current
        end
        
        fails.should be <= 3
      end
    end
  end
  
  describe '#sine' do
    it "should produce zero during every half-period, and non-zeros between" do
      @freqs.each do |freq|
        wave = SPCore::Oscillator.new(
          :sample_rate => @sample_rate,
          :frequency => freq,
          :wave_type => SPCore::Oscillator::WAVE_SINE
        )
        
        samples_in_half_period = @sample_rate / (2.0 * freq)
        
        wave.sample.should be_within(0.01).of(0.0)
        (samples_in_half_period - 1).to_i.times do
          wave.sample.should_not eq(0)
        end
        wave.sample.should be_within(0.01).of(0.0)
        
      end
    end
  end

end
