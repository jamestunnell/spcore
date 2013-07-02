#require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
#
#describe SPCore::CombFilter do
#  describe '#frequency_response' do
#    before :all do
#      @filters = []
#      [100].each do |frequency|
#        [0.15,0.25,0.5,0.75,0.85].each do |alpha|
#          @filters.push(
#            CombFilter.new(
#              :type => CombFilter::FEED_BACK,
#              :alpha => alpha,
#              :frequency => frequency
#            )
#          )
#        end
#      end
#    end
#    
#    it 'should produce the number of samples given by sample_count' do
#      [5,20,50].each do |sample_count|
#        @filters.each do |filter|
#          samples = filter.frequency_response(6000, sample_count)
#          samples.count.should eq(sample_count)
#        end
#      end
#    end
#    
#    it 'should...' do
#      outputs = {}
#      @filters.each do |filter|
#        outputs["comb filter: alpha = #{filter.alpha}, freq = #{filter.frequency}"] = filter.frequency_response 6000, 512
#      end
#      Plotter.plot_1d outputs
#    end
#  end
#end