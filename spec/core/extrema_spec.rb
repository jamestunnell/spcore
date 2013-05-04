require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SPCore::Extrema do
  context '#minima' do
    it 'should return points where local and global minima occur' do
      cases = {
        [3.8, 3.0, 2.9, 2.95, 3.6, 3.4, 2.8, 2.3, 2.1, 2.0, 2.5] => { 2 => 2.9, 9 => 2.0 },
        [3.2, 3.5, 2.9, 2.7, 2.8, 2.7, 2.5, 2.2, 2.4, 2.3, 2.0] => { 3 => 2.7, 7 => 2.2, 10 => 2.0 },
      }
        
      cases.each do |samples, minima|
        Extrema.new(samples).minima.should eq minima
      end
    end
  end
  
  context '#maxima' do
    it 'should return points where local and global maxima occur' do
      cases = {
        [3.8, 3.0, 2.9, 2.95, 3.6, 3.4, 2.8, 2.3, 2.1, 2.0, 2.5] => { 0 => 3.8, 4 => 3.6 },
        [3.2, 3.5, 2.9, 2.7, 2.8, 2.7, 2.5, 2.2, 2.4, 2.3, 2.0] => { 1 => 3.5, 4 => 2.8, 8 => 2.4},
      }
        
      cases.each do |samples, maxima|
        Extrema.new(samples).maxima.should eq maxima
      end
    end
  end
  
  context '#extrema' do
    it 'should return points where local and global extrema occur' do
      cases = {
        [3.8, 3.0, 2.9, 2.95, 3.6, 3.4, 2.8, 2.3, 2.1, 2.0, 2.5] => { 0 => 3.8, 2 => 2.9, 4 => 3.6, 9 => 2.0},
        [3.2, 3.5, 2.9, 2.7, 2.8, 2.7, 2.5, 2.2, 2.4, 2.3, 2.0] => { 1 => 3.5, 3 => 2.7, 4 => 2.8, 7 => 2.2, 8 => 2.4, 10 => 2.0},
      }
        
      cases.each do |samples, extrema|
        Extrema.new(samples).extrema.should eq extrema
      end
    end
  end
end