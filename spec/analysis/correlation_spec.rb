require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SPCore::Correlation do
  context 'image => triangular window' do
    before :all do
      @size = size = 48
      @triangle = TriangularWindow.new(size * 2).data
    end
    
    context 'feature => rising ramp (half size of triangular window)' do
      it 'should have maximum correlation at beginning' do
        rising_ramp = Array.new(@size){|i| i / @size.to_f }
        correlation = Correlation.new(@triangle, rising_ramp)
        correlation.data.first.should eq(correlation.data.max)
      end
    end
    
    context 'feature => falling ramp (half size of triangular window)' do
      it 'should have maximum correlation at end' do
        falling_ramp = Array.new(@size){|i| (@size - i) / @size.to_f }
        correlation = Correlation.new(@triangle, falling_ramp)
        correlation.data.last.should eq(correlation.data.max)
        
        Plotter.plot_1d "correlate falling ramp" => correlation.data
      end
    end
  end  
end