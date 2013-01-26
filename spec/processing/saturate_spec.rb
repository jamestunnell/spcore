require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'gnuplot'

describe SigProc::Saturation do
  it 'should not saturation below the threshold' do
    t = 0.5 # threshold
    
    x_data = []
    y_data = []
    z_data = []
    
    100.times do |n|
      percent = n / 100.0
      x = percent * SigProc::TWO_PI
      y = Math::sin x
      z = SigProc::Saturation.sigmoid y, t
      
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
