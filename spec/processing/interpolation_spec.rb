require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SigProc::Interpolation do
  context '.interpolate_linear' do
    it 'should interpolate floating-point values' do
      x1, y1 = 0.0, 2.0
      x2, y2 = 1.0, 4.0
      x3, y3 = 0.5, 3.0
      result = SigProc::Interpolation.linear x1, y1, x2, y2, x3
      result.should eq(y3)
    end

    it 'should interpolate integer values' do
      x1, y1 = 0, 20
      x2, y2 = 10, 40
      x3, y3 = 5, 30
      result = SigProc::Interpolation.linear x1, y1, x2, y2, x3
      result.should eq(y3)
    end
  end
end
