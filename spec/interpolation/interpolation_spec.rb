require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SPCore::Interpolation do
  context '.linear' do
    it 'should interpolate floating-point values' do
      result = SPCore::Interpolation.linear 2.0, 4.0, 0.5
      result.should eq(3.0)
    end

    it 'should interpolate integer values' do
      result = SPCore::Interpolation.linear 20, 40, 0.5
      result.should eq(30)
    end
  end

  context '.cubic_hermite' do
    it 'should look like...' do
      y0, y1, y2, y3 = 1.75, 1, 0.75, -1.5

      x_ary = []
      y_ary = []

      (0.0..1.0).step(0.05) do |x|
        y = SPCore::Interpolation.cubic_hermite y0, y1, y2, y3, x
        x_ary << x
        y_ary << y
      end

      #Gnuplot.open do |gp|
      #  Gnuplot::Plot.new(gp) do |plot|
      #    plot.title  "interpolated values"
      #    plot.xlabel "x"
      #    plot.ylabel "f(x)"
      #  
      #    plot.data = [            
      #      Gnuplot::DataSet.new( [ x_ary, y_ary ] ) { |ds|
      #        ds.with = "linespoints"
      #        ds.title = "cubic hermite"
      #        ds.linewidth = 1
      #      }
      #    ]
      #  end
      #end
    end
  end

end
