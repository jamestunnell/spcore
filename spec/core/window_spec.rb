require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SPCore::Window do
  def graph_window_data(x,y, window_name = "")
    Gnuplot.open do |gp|
      Gnuplot::Plot.new(gp) do |plot|
        plot.title  window_name + "window"
        plot.xlabel "x"
        plot.ylabel "f(x)"
      
        plot.data = [            
          Gnuplot::DataSet.new( [ x,y ] ) { |ds|
            ds.with = "linespoints"
            ds.title = window_name + "window"
            ds.linewidth = 1
          }
        ]
      end
    end
  end

  it 'should produce a window that looks like...' do
    #size = 512
    #x_ary = []
    #
    #(0...size).step(1) do |n|
    #  x_ary[n] = n
    #end
    #
    #SPCore::Window::TYPES.each do |window_type|
    #  window = SPCore::Window.new(size, window_type)
    #  graph_window_data(x_ary,window.data, window_type.to_s)
    #end
  end
end
