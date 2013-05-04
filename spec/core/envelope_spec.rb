require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SPCore::Envelope do
  it 'should produce an output that follows the amplitude of the input' do
    sample_rate = 400
    sample_count = sample_rate
    generator = SignalGenerator.new(:size => sample_count, :sample_rate => sample_rate)
    base_signal = generator.make_signal [sample_rate / 5.0]    
    modulation_signal = generator.make_signal [sample_rate / 80.0]
    base_signal.multiply! modulation_signal
    
    envelope = base_signal.envelope
    
    Plotter.new(
      :title => "signal and envelope",
      :xlabel => "sample",
      :ylabel => "values",
    ).plot_1d(
      "signal" => base_signal.data,
      "modulation" => modulation_signal.data,
      "envelope" => envelope.data,
    )
    
    max_diff = 0.1
    sample_count.times do |n|
      envelope.data[n].should be_within(max_diff).of(modulation_signal.data[n].abs)
    end
  end
end
