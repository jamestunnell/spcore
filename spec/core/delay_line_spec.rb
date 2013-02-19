require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SPCore::DelayLine do
  it 'should' do
    SAMPLE_RATE = 400.0
    MAX_DELAY_SEC = 0.1
    
    5.times do
      delay_line = SPCore::DelayLine.new(
        :sample_rate => SAMPLE_RATE,
        :max_delay_seconds => MAX_DELAY_SEC,
        :delay_seconds => (rand * MAX_DELAY_SEC)
      )
      
      rand_sample = rand
      delay_line.push_sample rand_sample
      delay_line.delay_samples.times do
        delay_line.push_sample 0.0
      end
      
      delay_line.delayed_sample.should eq(rand_sample)
    end
  end
end
