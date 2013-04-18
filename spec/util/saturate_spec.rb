require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'gnuplot'

describe SPCore::Saturation do
  describe '.tanh' do
    it 'should not saturate below the threshold' do
      t = 1.0 # threshold
      
      x_data = []
      y_data = []
      z_data = []
      
      osc = SPCore::Oscillator.new(
        :sample_rate => 100,
        :frequency => 1.0,
        :wave_type => SPCore::Oscillator::WAVE_SINE,
        :amplitude => 2.5
      )
      
      (4 * osc.sample_rate / osc.frequency).to_i.times do |n|
        x = n / osc.sample_rate
        y = osc.sample
        z = SPCore::Saturation.sigmoid y, t
        
        if y.abs < t
          z.should eq(y)
        end
        
        x_data << x
        y_data << y
        z_data << z
      end

      #Gnuplot.open do |gp|
      #  Gnuplot::Plot.new(gp) do |plot|
      #    plot.title  "signal and saturated signal"
      #    plot.xlabel "input"
      #    plot.ylabel "output"
      #  
      #    plot.data = [
      #      Gnuplot::DataSet.new( [x_data, y_data] ){ |ds|
      #        ds.with = "lines"
      #        ds.title = "Signal"
      #        #ds.linewidth = 4
      #      },
      #      Gnuplot::DataSet.new( [x_data, z_data] ){ |ds|
      #        ds.with = "lines"
      #        ds.title = "Saturated signal"
      #        #ds.linewidth = 4
      #      }
      #    ]
      #  end
      #end
    end
  end
  
  describe '.gompertz' do
    it 'should...saturate' do
      t = 1.0 # threshold
      
      x_data = []
      y_data = []
      z_data = []
      
      osc = SPCore::Oscillator.new :sample_rate => 100, :frequency => 1.0, :wave_type => SPCore::Oscillator::WAVE_SINE, :amplitude => 2.5
      (4 * osc.sample_rate / osc.frequency).to_i.times do |n|
        x = n / osc.sample_rate
        y = osc.sample
        z = SPCore::Saturation.gompertz y, t
        
        #z.should ???

        x_data << x
        y_data << y
        z_data << z
      end
      
      #Gnuplot.open do |gp|
      #  Gnuplot::Plot.new(gp) do |plot|
      #    plot.title  "signal and saturated signal"
      #    plot.xlabel "input"
      #    plot.ylabel "output"
      #  
      #    plot.data = [
      #      Gnuplot::DataSet.new( [x_data, y_data] ){ |ds|
      #        ds.with = "lines"
      #        ds.title = "Signal"
      #        #ds.linewidth = 4
      #      },
      #      Gnuplot::DataSet.new( [x_data, z_data] ){ |ds|
      #        ds.with = "lines"
      #        ds.title = "Saturated signal"
      #        #ds.linewidth = 4
      #      }
      #    ]
      #  end
      #end
    end
  end
end
