require 'test/unit'
require './jobs/conversion_calc'

class TestAdd < Test::Unit::TestCase
    def test_build
        ConversionCalc.build_campaign(
            File.dirname(__FILE__) +'/../csv/1/clicks_1.csv',
            File.dirname(__FILE__) +'/../csv/1/conversions_1.csv')

        ConversionCalc.add_banner(1, 1)
        ConversionCalc.add_banner(2, 1)
        ConversionCalc.add_banner(1, 2)
        ConversionCalc.add_click(1, 1, 1)
        ConversionCalc.add_click(2, 1, 1)
        ConversionCalc.add_click(3, 1, 1)
        ConversionCalc.add_conversion(1, 2, 0.5)
        ConversionCalc.add_conversion(1, 3, 0.5)
        ConversionCalc.calculate

        # Check recorded conversions per campaign
        assert_equal ConversionCalc.get_conversions(:campaign_id = 1), {1 => 1.0, 2 => 0}
        assert_equal ConversionCalc.get_conversions(:campaign_id = 2), {1 => 1.0}

        # Check recorded numbers of clicks per campaign
        assert_equal ConversionCalc.get_clicks(:campaign_id = 1), {1 => 3, 2 => 0}
        assert_equal ConversionCalc.get_clicks(:campaign_id = 2), {1 => 0}
    end
end