require 'gnuplot'

module SPCore
class Plotter
  include Hashmake::HashMakeable
  
  ARG_SPECS = [
    Hashmake::ArgSpec.new(:key => :title, :type => String, :reqd => false, :default => ""),
    Hashmake::ArgSpec.new(:key => :xlabel, :type => String, :reqd => false, :default => "x"),
    Hashmake::ArgSpec.new(:key => :ylabel, :type => String, :reqd => false, :default => "y"),
    Hashmake::ArgSpec.new(:key => :linestyle, :type => String, :reqd => false, :default => "lines", :validator => ->(a){ Plotter.valid_linestle? a }),
    Hashmake::ArgSpec.new(:key => :linewidth, :type => Fixnum, :reqd => false, :default => 1, :validator => ->(a){ a >= 1 }),
  ]
  
  def initialize hashed_args
    hash_make Plotter::ARG_SPECS, hashed_args
  end
  
  def self.valid_linestle? linestyle
    ["lines"].include? linestyle.downcase
  end
  
  def plot_sequences sequences
    if sequences.is_a?(Array) # no titles given, name them according to order
      titled_sequences = {}
      sequences.each_index do |i|
        titled_sequences["Sequence #{i}"] = sequences[i]
      end
      sequences = titled_sequences
    end
    
    title = @title.empty? ? "Sequences" : @title
    xlabel = @xlabel.empty? ? "sample number (n)" : @xlabel
    ylabel = @ylabel.empty? ? "sample (y[n])" : @ylabel
    
    Gnuplot.open do |gp|
      Gnuplot::Plot.new(gp) do |plot|
        plot.title  title
        plot.xlabel xlabel
        plot.ylabel ylabel
        
        plot.data = []
        
        sequences.each do |dataset_title, sequence|
          indices = Array.new(sequence.size)
          sequence.each_index do |i|
            indices[i] = i
          end
          
          dataset = Gnuplot::DataSet.new( [indices, sequence] ){ |ds|
            ds.with = @linestyle
            ds.title = dataset_title
            ds.linewidth = @linewidth
          }
          plot.data << dataset
        end
      end
    end
  end
end
end
