require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SPCore::Envelope do
  before :all do
    sample_rate = 1000
    sample_count = 512 * 2
    generator = SignalGenerator.new(:size => sample_count, :sample_rate => sample_rate)
    
    @modulation_signal = generator.make_signal [4.0], :amplitude => 0.1
    @modulation_signal.multiply! BlackmanWindow.new(sample_count).data

    @base_signal = generator.make_signal [64.0]
    @base_signal.multiply! @modulation_signal
  end

  it 'should produce an output that follows the amplitude of the input' do
    envelope = @base_signal.envelope
    check_envelope(envelope)
  end
  
  def check_envelope envelope    
    #signals = {
    #  "signal" => @base_signal,
    #  "modulation (abs)" => @modulation_signal.abs,
    #  "envelope" => envelope,
    #}
    #
    #Plotter.new(
    #  :title => "signal and envelope",
    #  :xlabel => "sample",
    #  :ylabel => "values",
    #).plot_signals(signals)
    
    #Plotter.new().plot_2d("envelop freq magnitudes" => envelope.freq_magnitudes)
    
    begin
      ideal = @modulation_signal.energy
      actual = envelope.energy
      error = (ideal - actual).abs / ideal
      error.should be_within(0.1).of(0.0)
    end
    
    begin
      ideal = @modulation_signal.rms
      actual = envelope.rms
      error = (ideal - actual).abs / ideal
      error.should be_within(0.1).of(0.0)
    end
  end
end
