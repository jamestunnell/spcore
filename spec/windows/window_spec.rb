require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'windows' do
  it 'should produce a window that looks like...' do
    size = 512
    
    window_classes = [
      #SPCore::RectangleWindow,
      #SPCore::HannWindow,
      #SPCore::HammingWindow,
      #SPCore::CosineWindow,
      #SPCore::LanczosWindow,
      #SPCore::TriangleWindow,
      #SPCore::BartlettWindow,
      #SPCore::GaussWindow,
      #SPCore::BartlettHannWindow,
      #SPCore::BlackmanWindow,
      #SPCore::NuttallWindow,
      #SPCore::BlackmanHarrisWindow,
      #SPCore::BlackmanNuttallWindow,
      #SPCore::FlatTopWindow
    ]
    
    windows = {}
    window_classes.each do |window_class|
      windows[window_class.to_s] = window_class.new(size).data
    end
    
    if windows.any?
      Plotter.new(:title => "windows").plot_1d windows
    end
  end
end
