require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SPCore::FrequencyDomain do
  
  describe '.freq_peaks' do
    it 'should find the peak frequency components' do
      cases = [
        [40.0, 160.0, 250.0],
      ]
      
      cases.each do |ideal_peaks|
        generator = SignalGenerator.new(:sample_rate => 2000, :size => 256)
        signal = generator.make_signal(ideal_peaks)
        actual_peaks = FrequencyDomain.freq_peaks(signal.data, signal.sample_rate)
        
        actual_peak_freqs = actual_peaks.keys
        
        actual_peak_freqs.count.should eq(ideal_peaks.count)
        ideal_peaks.count.times do |i|
          actual_peak_freqs[i].should be_within(5.0).of(ideal_peaks[i])
        end        
      end
    end
  end

  describe '.fundamental' do
    context 'harmonic series present' do
      it 'should find the fundamental component when a single harmonic series is present' do
        cases = {
          [40.0, 80.0, 120.0, 160.0] => 40.0,
          [25.0, 50.0] => 25.0,
          [100.0, 200.0, 300.0, 400.0] => 100.0,
        }
        
        cases.each do |freqs, fundamental|
          generator = SignalGenerator.new(:sample_rate => 2000, :size => 512)
          signal = generator.make_signal(freqs)
          signal.fundamental.should be_within(5.0).of(fundamental)
        end
      end

      it 'should find the fundamental component when a harmonic series is present along with other non-series components' do
        cases = {
          [30.0, 40.0, 80.0, 100.0, 120.0, 160.0] => 40.0,
          [25.0, 50.0, 90.0] => 25.0,
          [60.0, 100.0, 200.0, 250.0, 300.0, 400.0, 550.0] => 100.0,
        }
        
        cases.each do |freqs, fundamental|
          generator = SignalGenerator.new(:sample_rate => 2000, :size => 512)
          signal = generator.make_signal(freqs)
          signal.fundamental.should be_within(5.0).of(fundamental)
        end
      end
      
      it 'should find the fundamental component of the longest harmonic series present when multiple series are present' do
        cases = {
          [58.0, 116.0, 174.0, 200.0, 400.0, 600.0, 800.0] => 200.0,
          [66.0, 132.0, 198.0, 264.0, 300.0, 600.0, 900.0] => 66.0,
        }
        
        cases.each do |freqs, fundamental|
          generator = SignalGenerator.new(:sample_rate => 2000, :size => 512)
          signal = generator.make_signal(freqs)
          signal.fundamental.should be_within(5.0).of(fundamental)
        end
      end
    end
    
    context 'no harmonic series preset' do
      it 'should return the strongest peak frequency' do
        cases = [
           {:strongest_peak => 40.0, :other_peaks => [160.0, 250.0]}
        ]
        
        generator = SignalGenerator.new(:sample_rate => 2000, :size => 512)
        cases.each do |hash|
          signal = generator.make_signal([hash[:strongest_peak]], :amplitude => 1.5)
          signal.add!(generator.make_signal(hash[:other_peaks]))
          signal.fundamental.should be_within(5.0).of(hash[:strongest_peak])
        end
      end
    end
  end
end