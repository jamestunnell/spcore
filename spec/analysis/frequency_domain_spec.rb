require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'wavefile'

describe SPCore::FrequencyDomain do
  before :all do
    @freq_tolerance = 0.1
  end
  
  def match_arrays_with_tolerance ideal, actual, tolerance
    actual.count.should eq ideal.count
    actual.count.times do |i|
      item_ideal = ideal[i]
      item_actual = actual[i]
      
      percent_error = (item_ideal - item_actual).abs / item_ideal
      percent_error.should be_within(tolerance).of(0.0)
    end
  end
  
  def check_tolerance ideal, actual, tolerance_percent
    margin = ideal * tolerance_percent
    actual.should be_between(ideal - margin, ideal + margin)
  end
  
  def verify_harmonic_series series, tolerance_percent
    fund = series.first
    for i in 1...series.count
      freq = series[i]
      ratio = freq / fund
      target = ratio * fund
      
      check_tolerance target, freq, tolerance_percent
    end
  end
  
  describe '.peaks' do
    it 'should find the peak frequency components' do
      cases = [
        [20.0, 80.0, 125.0],
      ]
      
      cases.each do |ideal_peaks|
        generator = SignalGenerator.new(:sample_rate => 1000, :size => 256)
        signal = generator.make_signal(ideal_peaks)
        actual_peaks = signal.freq_peaks
        match_arrays_with_tolerance ideal_peaks, actual_peaks.keys, @freq_tolerance
      end
    end
  end

  describe '.harmonic_series' do
    context 'harmonic series present' do
      it 'should find the fundamental component when a harmonic series is present along with other non-series components' do
        cases = {
          [30.0, 50.0, 100.0, 125.0, 150.0, 200.0, 275.0] => 50.0,
          [15.0, 20.0, 40.0, 50.0, 60.0, 80.0] => 20.0,
          [25.0, 50.0, 85.0] => 25.0,
        }
        
        cases.each do |freqs, fundamental|
          generator = SignalGenerator.new(:sample_rate => 1000, :size => 512)
          signal = generator.make_signal(freqs)
          
          series = signal.harmonic_series
          check_tolerance fundamental, series.first, @freq_tolerance
          verify_harmonic_series series, @freq_tolerance
        end
      end
  
      it 'should find all the components when only a single harmonic series is present' do
        cases = {
          [30.0, 60.0, 90.0, 120.0] => 30.0,
          [25.0, 50.0] => 25.0,          
          [50.0, 100.0, 150.0, 200.0] => 50.0,
        }
        
        cases.each do |ideal_freqs, fundamental|
          generator = SignalGenerator.new(:sample_rate => 1000, :size => 512)
          signal = generator.make_signal(ideal_freqs)
          
          series = signal.harmonic_series
          check_tolerance fundamental, series.first, @freq_tolerance
          verify_harmonic_series series, @freq_tolerance
        end
      end
      
      it 'should find the fundamental component of the longest harmonic series present when multiple series are present' do
        cases = {
          [29.0, 58.0, 87.0, 100.0, 200.0, 300.0, 400.0] => 100.0,
          [33.0, 66.0, 99.0, 132.0, 150.0, 300.0, 450.0] => 33.0,
        }
        
        cases.each do |freqs, fundamental|
          generator = SignalGenerator.new(:sample_rate => 1000, :size => 512)
          signal = generator.make_signal(freqs)
          
          series = signal.harmonic_series
          check_tolerance fundamental, series.first, @freq_tolerance
          verify_harmonic_series series, @freq_tolerance
        end
      end
    end
    
    context 'no harmonic series preset' do
      it 'should return the strongest peak frequency' do
        cases = [
           {:strongest_peak => 37.0, :other_peaks => [80.0, 125.0]},
           {:strongest_peak => 44.0, :other_peaks => [99.0, 155.0]}
        ]
        
        generator = SignalGenerator.new(:sample_rate => 1000, :size => 256)
        cases.each do |hash|
          signal = generator.make_signal([hash[:strongest_peak]], :amplitude => 1.5)
          signal.add!(generator.make_signal(hash[:other_peaks]))
          signal.fundamental.should be_within(5.0).of(hash[:strongest_peak])
        end
      end
    end
    
    context 'real-world sound files' do
      it 'should produce a series with the expected fundamental freq' do
        cases = {
          "trumpet_B4.wav" => 493.883,
          "piano_C4.wav" => 261.626,
        }
        
        cases.each do |filename,ideal_fundamental|
          file_path = File.dirname(__FILE__) + "/#{filename}"
          WaveFile::Reader.new(file_path) do |reader|
            read_size = reader.total_sample_frames
            sample_frames = reader.read(read_size).samples
            
            # if multiple channels are in the file, only use the 1st channel
            if reader.format.channels == 1
              data = sample_frames
            else
              data = sample_frames.map { |sample_frame| sample_frame[0] }
            end
            
            signal = SPCore::Signal.new(:data => data, :sample_rate => reader.format.sample_rate)
            series = signal.harmonic_series
            check_tolerance ideal_fundamental, series.min, @freq_tolerance
          end          
        end
      end
    end
  end
end