require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'gnuplot'
require 'pry'

describe 'cookbook filter' do
  #it 'should produce a nice frequency response graph' do
  #  sample_rate = 44000.0
  #  crit_freq = 1000.0
  #  max_test_freq = 10000.0
  #  bw = 2
  #  filter = SigProc::CookbookNotchFilter.new sample_rate
  #  filter.set_critical_freq_and_bw crit_freq, bw
  #  
  #  freqs = []
  #  dbs = []
  #  
  #  start_freq = 10.0
  #  test_freq = start_freq
  #  
  #  200.times do
  #    mag = filter.get_freq_magnitude_response test_freq
  #
  #    dbs << SigProc::Gain.linear_to_db(mag)
  #    freqs << test_freq
  #    
  #    test_freq *= 1.035
  #  end
  #
  #  Gnuplot.open do |gp|
  #    Gnuplot::Plot.new(gp) do |plot|
  #      plot.title  "Frequency Magnitude Response for Lowpass Filter with Critical Freq of #{crit_freq} and BW of #{bw}"
  #      plot.xlabel "Frequency (f)"
  #      plot.ylabel "Frequency Magnitude Response (dB) at f"
  #      plot.logscale 'x'
  #    
  #      plot.data << Gnuplot::DataSet.new( [freqs, dbs] ) do |ds|
  #        ds.with = "linespoints"
  #        #ds.linewidth = 4
  #      end
  #    end
  #  end
  #  
  #end
end
