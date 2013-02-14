require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SPCore::SignalGenerator do
  before :all do
    @sample_rate = 600.0
    @test_freqs = [
      65.0, 100.0, 250.0
    ]
  end
  
  context '.make_signal' do
    context 'one freq at a time' do
      it 'should produce the same output as a plain Oscillator' do
        size = 60
        generator = SignalGenerator.new :sample_rate => @sample_rate, :size => size
        
        @test_freqs.each do |freq|
          signal = generator.make_signal [freq]
          
          osc = Oscillator.new(:sample_rate => @sample_rate, :frequency => freq)
          osc_output = Array.new(size)
          size.times do |i|
            osc_output[i] = osc.sample
          end
          
          signal.data.should eq(osc_output)
        end
      end
    end

    context 'many freqs at a time' do
      it 'should produce the same output as equivalent plain Oscillators' do
        size = 60
        generator = SignalGenerator.new :sample_rate => @sample_rate, :size => size
        
        oscs = []
        @test_freqs.each do |freq|
          oscs.push Oscillator.new(:sample_rate => @sample_rate, :frequency => freq)
        end
        
        signal = generator.make_signal @test_freqs

        osc_output = Array.new(size, 0.0)
        size.times do |i|
          oscs.each do |osc|
            osc_output[i] += osc.sample
          end
        end
          
        signal.data.should eq(osc_output)
      end
    end
  end
end
