require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'gnuplot'
require 'pry'

describe 'cookbook filter' do
  it 'should produce a nice frequency response graph' do
    #sample_rate = 4000.0
    #crit_freq = 400.0
    #min_test_freq = 10.0
    #max_test_freq = (sample_rate / 2.0) - 1.0
    #bw = 0.3
    #
    #[SPCore::CookbookLowpassFilter, SPCore::CookbookHighpassFilter, SPCore::CookbookBandpassFilter].each do |filter_class|
    #  filter = filter_class.new sample_rate
    #  filter.set_critical_freq_and_bw crit_freq, bw
    #  
    #  freq_response = {}
    #  Scale.exponential(min_test_freq..max_test_freq, 200).each do |freq|
    #    mag = filter.get_freq_magnitude_response freq
    #    freq_response[freq] = SPCore::Gain.linear_to_db(mag)
    #  end
    #  
    #  plotter = Plotter.new(
    #    :title => "Frequency Magnitude Response for #{filter_class} with critical freq of #{crit_freq}",
    #    :logscale => "x"
    #  )
    #  plotter.plot_2d "magnitude (dB)" => freq_response
    #end
  end
end
