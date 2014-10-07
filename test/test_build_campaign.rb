require 'test/unit'
require './lib/conversion_calc'

class TestAdd < Test::Unit::TestCase
    def test_build
        #ConversionCalc.build_campaign(
        #    File.dirname(__FILE__) +'/../csv/1/clicks_1.csv',
        #    File.dirname(__FILE__) +'/../csv/1/conversions_1.csv')
        calc = ConversionCalc.new

        calc.add_banner(1, 1)
        calc.add_banner(2, 1)
        calc.add_banner(1, 2)
        calc.add_click(1, 1, 1)
        calc.add_click(2, 1, 1)
        calc.add_click(3, 1, 1)
        calc.add_conversion(1, 2, 0.5)
        calc.add_conversion(1, 3, 0.5)
        calc.calculate

        assert_equal [1, 2], calc.get_top_banner_ids(1)
        assert_equal [1], calc.get_top_banner_ids(2)
=begin
        # Check recorded conversions per campaign
        assert_equal calc.get_conversions(campaign_id: 1), {1 => 1.0, 2 => 0}
        assert_equal calc.get_conversions(campaign_id: 2), {1 => 1.0}

        # Check recorded numbers of clicks per campaign
        assert_equal calc.get_clicks(campaign_id: 1), {1 => 3, 2 => 0}
        assert_equal calc.get_clicks(campaign_id: 2), {1 => 0}
=end
    end
end
