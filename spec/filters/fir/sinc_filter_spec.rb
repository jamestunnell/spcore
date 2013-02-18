require 'pry'
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe SPCore::SincFilter do
  before :all do
    @sample_rate = 4000.0
    @orders = [62,126,254]
    @cutoffs = Scale.exponential 400.0..1600.0, 4
  end
  
  context '.highpass' do
    it 'should keep magnitude below-20 dB below cutoff and close to 0 dB above cutoff' do
      @orders.each do |order|
        @cutoffs.each do |cutoff|
          if order % 2 == 1
            order += 1
          end
          filter = SincFilter.new :order => order, :cutoff_freq => cutoff, :sample_rate => @sample_rate, :window_class => BlackmanWindow
          #filter.highpass_fir.plot_freq_response false
          freq_response = filter.highpass_fir.freq_response true
          
          freq_response.each do |freq, magnitude|
            if freq <= (0.8 * cutoff)
              magnitude.should be < -20.0 # using dB
            elsif freq >= (1.2 * cutoff)
              magnitude.should be_within(1.0).of(0.0) # using dB
            end
          end
        end
      end
    end
  end
  
  context '.lowpass' do
    it 'should keep magnitude close to 0 dB below cutoff and below-20 dB above cutoff' do
      @orders.each do |order|
        @cutoffs.each do |cutoff|
          if order % 2 == 1
            order += 1
          end
          filter = SincFilter.new :order => order, :cutoff_freq => cutoff, :sample_rate => @sample_rate, :window_class => BlackmanWindow
          #filter.lowpass_fir.plot_freq_response false
          freq_response = filter.lowpass_fir.freq_response true
          
          freq_response.each do |freq, magnitude|
            if freq <= (0.8 * cutoff)
              magnitude.should be_within(1.0).of(0.0) # using dB
            elsif freq >= (1.2 * cutoff)
              magnitude.should be < -20.0 # using dB
            end
          end
        end
      end
    end
  end

end
