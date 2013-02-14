require 'gnuplot'

module SPCore
class Plotter
  include Hashmake::HashMakeable
  
  ARG_SPECS = [
    Hashmake::ArgSpec.new(:key => :title, :type => String, :reqd => false, :default => ""),
    Hashmake::ArgSpec.new(:key => :xlabel, :type => String, :reqd => false, :default => "x"),
    Hashmake::ArgSpec.new(:key => :ylabel, :type => String, :reqd => false, :default => "y"),
    Hashmake::ArgSpec.new(:key => :linestyle, :type => String, :reqd => false, :default => "lines"),
    Hashmake::ArgSpec.new(:key => :linewidth, :type => Fixnum, :reqd => false, :default => 1, :validator => ->(a){ a >= 1 }),
    Hashmake::ArgSpec.new(:key => :logscale, :type => String, :reqd => false, :default => ""),
  ]
  
  def initialize hashed_args
    hash_make Plotter::ARG_SPECS, hashed_args
  end
  
  def plot_2d titled_hashes
    datasets = []
    titled_hashes.each do |title, hash|
      dataset = Gnuplot::DataSet.new( [hash.keys, hash.values] ){ |ds|
        ds.with = @linestyle
        ds.title = title
        ds.linewidth = @linewidth
      }
      datasets << dataset
    end
    
    plot_datasets datasets
  end
  
  def plot_1d titled_sequences
    datasets = []
    sequences.each do |title, sequence|
      indices = Array.new(sequence.size)
      sequence.each_index do |i|
        indices[i] = i
      end
      
      dataset = Gnuplot::DataSet.new( [indices, sequence] ){ |ds|
        ds.with = @linestyle
        ds.title = title
        ds.linewidth = @linewidth
      }
      datasets << dataset
    end
    
    plot_datasets datasets
  end

  def plot_datasets datasets
    Gnuplot.open do |gp|
      Gnuplot::Plot.new(gp) do |plot|
        plot.title  @title
        plot.xlabel @xlabel
        plot.ylabel @ylabel
        plot.data = datasets
        
        if @logscale_x
          plot.logscale "x"
        end
      end
    end
  end
end
end
