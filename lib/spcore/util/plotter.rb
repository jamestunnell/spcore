require 'gnuplot'

module SPCore

# Helps make plotting data even easier. Uses gnuplot.
class Plotter
  include Hashmake::HashMakeable
  
  # Used to process hashed args passed to #initialize.
  ARG_SPECS = {
    :title => arg_spec(:type => String, :reqd => false, :default => ""),
    :xlabel => arg_spec(:type => String, :reqd => false, :default => "x"),
    :ylabel => arg_spec(:type => String, :reqd => false, :default => "y"),
    :linestyle => arg_spec(:type => String, :reqd => false, :default => "lines"),
    :linewidth => arg_spec(:type => Fixnum, :reqd => false, :default => 1, :validator => ->(a){ a >= 1 }),
    :logscale => arg_spec(:type => String, :reqd => false, :default => ""),
  }
  
  # A new instance of Plotter.
  # @param [Hash] hashed_args A hash containing initialization parameters.
  #                           All params are optional. See ARG_SPECS for
  #                           parameter details.
  def initialize hashed_args = {}
    hash_make Plotter::ARG_SPECS, hashed_args
  end
  
  # Plot XY datapoints.
  # @param [Hash] titled_hashes A hash that maps dataset titles to data. The data itself
  #                             is a hash also, that maps x values to y values.
  #
  # @example
  #   Plotter.plot_2d "somedata" => {0.0 => 4.0, 1.0 => 2.0}
  def plot_2d titled_hashes
    datasets = []
    titled_hashes.each do |title, hash|
      # sort the data
      
      sorted = {}
      hash.keys.sort.each do |key|
        sorted[key] = hash[key]
      end
      
      dataset = Gnuplot::DataSet.new( [sorted.keys, sorted.values] ){ |ds|
        ds.with = @linestyle
        ds.title = title
        ds.linewidth = @linewidth
      }
      datasets << dataset
    end
    
    plot_datasets datasets
  end

  # Plot a sequence of values.
  # @param [Hash] titled_sequences A hash that maps sequence titles to data. The data itself
  #                             is an array of values. In the plot, values will be mapped to
  #                             their index in the sequence.
  # @param plot_against_fraction If true, instead of plotting samples against sample number, plot
  #                              them against the fraction (sample_number / total_samples).
  #
  # @example
  #   Plotter.plot_1d "somedata" => [0,2,3,6,3,-1]
  def plot_1d titled_sequences
    datasets = []
    titled_sequences.each do |title, sequence|
      indices = Array.new(sequence.size)
      sequence.each_index do |i|
        indices[i] = i
        #if plot_against_fraction
        #  indices[i] /= sequence.size.to_f
        #end
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

  # Plot Gnuplot::DataSet objects.
  # @param [Array] datasets An array of Gnuplot::DataSet objects.
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
  
  def plot_signals signals_hash
    data_hash = {}
    signals_hash.each do |name, signal|
      data_hash[name] = signal.data
    end
    plot_1d data_hash
  end
end
end
