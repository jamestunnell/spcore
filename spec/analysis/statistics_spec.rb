require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SPCore::Statistics do
  describe '.mean' do
    it 'should calculate the proper mean' do
      cases = {
        [1,2,3,4,5] => 3,
        [11,25,60,4,22,48,40] => 30,
        [100,200] => 150,
      }
      
      cases.each do |values,ideal_mean|
        actual_mean = Statistics.mean values
        actual_mean.should eq(ideal_mean)
      end
    end
  end
  
  describe '.std_dev' do
    it 'should determine the proper standard deviation' do
      cases = {
        [4,2,5,8,6] => 2.24,
        [2,4,4,4,5,5,7,9] => 2,
        [1,2,3,4,5] => 1.414
      }
      
      cases.each do |inputs,expected_output|
        actual_output = Statistics.std_dev inputs
        actual_output.should be_within(0.01).of(expected_output)
      end      
    end
  end
  
  describe '.correlation' do
    context 'image => triangular window' do
      before :all do
        @size = size = 48
        @triangle = TriangularWindow.new(size * 2).data
      end
      
      context 'feature => rising ramp (half size of triangular window)' do
        it 'should have maximum correlation at beginning' do
          rising_ramp = Array.new(@size){|i| i / @size.to_f }
          correlation = Statistics.correlation(@triangle, rising_ramp)
          correlation.first.should eq(correlation.max)
        end
      end
      
      context 'feature => falling ramp (half size of triangular window)' do
        it 'should have maximum correlation at end' do
          falling_ramp = Array.new(@size){|i| (@size - i) / @size.to_f }
          correlation = Statistics.correlation(@triangle, falling_ramp)
          correlation.last.should eq(correlation.max)
          
          #Plotter.plot_1d "correlate falling ramp" => correlation
        end
      end
    end  
  end

end
