require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SPCore::EnvelopeDetector do
  describe '#process_sample' do
    it 'should produce an output that follows the amplitude of the input' do
      sample_rate = 10000.0
      freqs = [20.0, 200.0, 2000.0]

      envelope_start = 1.0
      envelope_end = 0.0
      
      freqs.each do |freq|
        osc = SPCore::Oscillator.new :sample_rate => sample_rate, :frequency => freq, :amplitude => envelope_start
        detector = SPCore::EnvelopeDetector.new :sample_rate => sample_rate, :attack_time => (1e-2 / freq), :release_time => (1.0 / freq)
        
        # 1 full period to acclimate the detector to the starting envelope
        (sample_rate / freq).to_i .times do
          detector.process_sample osc.sample
        end
        
        input = []
        output = []
        envelope = []
        
        # 5 full periods to track the envelope as it changes
        sample_count = (5.0 * sample_rate / freq).to_i
        sample_count.times do |n|
          percent = n.to_f / sample_count
          amplitude = SPCore::Interpolation.linear envelope_start, envelope_end, percent
          osc.amplitude = amplitude
          
          sample = osc.sample
          env = detector.process_sample sample        
          
          input << n
          output << sample
          envelope << env
          
          env.should be_within(0.25).of(amplitude)
        end
        
        ## plot the data
        # 
        #Gnuplot.open do |gp|
        #  Gnuplot::Plot.new( gp ) do |plot|
        #  
        #    plot.title  "Signal and Envelope"
        #    plot.ylabel "sample n"
        #    plot.xlabel "y[n]"
        #    
        #    plot.data = [
        #      Gnuplot::DataSet.new( [input, output] ) { |ds|
        #        ds.with = "lines"
        #        ds.title = "Signal"
        #        ds.linewidth = 2
        #      },
        #    
        #      Gnuplot::DataSet.new( [ input, envelope ] ) { |ds|
        #        ds.with = "lines"
        #        ds.title = "Envelope"
        #        ds.linewidth = 2
        #      }
        #    ]
        #
        #  end
        #end

      end
    end
  end
end
