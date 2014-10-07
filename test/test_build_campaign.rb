require 'test/unit'
require './jobs/conversion_calc'

class TestAdd < Test::Unit::TestCase
    def test_build
        ConversionCalc.build_campaign(
            File.dirname(__FILE__) +'/../csv/1/clicks_1.csv',
            File.dirname(__FILE__) +'/../csv/1/conversions_1.csv')

        banners = ConversionCalc.get_conversions(:campaign_id = 1)
        assert_equal banners.length, 5
    end
end