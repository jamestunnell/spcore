require 'pry'
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SPCore::SincFilter do
  before :all do
    @sample_rate = 4000.0
    @orders = Scale.linear 100..200, 4
    @left_cutoffs = Scale.exponential 300.0..1500.0, 4
    @right_cutoffs = Scale.exponential 400.0..1600.0, 4
  end
  
  context '.bandpass' do
    it 'should keep magnitude below -20 dB below left cutoff and above right cutoff, and close to 0 dB between' do
      @orders.each do |order|
        @left_cutoffs.each_index do |i|
          left_cutoff = @left_cutoffs[i]
          right_cutoff = @right_cutoffs[i]
          
          if order % 2 == 1
            order += 1
          end
          filter = DualSincFilter.new :order => order, :left_cutoff_freq => left_cutoff, :right_cutoff_freq => right_cutoff, :sample_rate => @sample_rate, :window_class => BlackmanWindow
          #filter.highpass_fir.plot_freq_response @sample_rate, false
          freq_response = filter.bandpass_fir.freq_response @sample_rate
          
          freq_response.each do |freq, magnitude|
            if freq <= (0.8 * left_cutoff) || freq >= (1.2 * right_cutoff)
              magnitude.should be < -20.0 # using dB
            elsif freq.between?(1.2 * left_cutoff, 0.8 * right_cutoff)
              magnitude.should be_within(1.0).of(0.0) # using dB
            end
          end
        end
      end
    end
  end
  
  context '.bandstop' do
    it 'should keep magnitude close to 0 dB below left cutoff and above right cutoff, and below -20 dB between' do
      @orders.each do |order|
        @left_cutoffs.each_index do |i|
          left_cutoff = @left_cutoffs[i]
          right_cutoff = @right_cutoffs[i]
          
          if order % 2 == 1
            order += 1
          end
          filter = DualSincFilter.new :order => order, :left_cutoff_freq => left_cutoff, :right_cutoff_freq => right_cutoff, :sample_rate => @sample_rate, :window_class => BlackmanWindow
          #filter.highstop_fir.plot_freq_response @sample_rate, false
          freq_response = filter.bandstop_fir.freq_response @sample_rate
          
          freq_response.each do |freq, magnitude|
            if freq <= (0.8 * left_cutoff) || freq >= (1.2 * right_cutoff)
              magnitude.should be_within(1.0).of(0.0) # using dB
            elsif freq.between?(1.2 * left_cutoff, 0.8 * right_cutoff)
              magnitude.should be < -20.0 # using dB
            end
          end
        end
      end
    end
  end
  
end
