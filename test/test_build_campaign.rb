require 'test/unit'
require './lib/conversion_calc'

class TestAdd < Test::Unit::TestCase
    def test_build
        calc = ConversionCalc.new

        (1..3).each do |campaign_id|
            (1..11).each do |banner_id|
                calc.add_impression(banner_id, campaign_id)
            end
        end

        ########################################################################
        # first campaign has 11 banners with conversions
        campaign_id = 1
        (1..11).each do |banner_id|
            click_id = banner_id
            conversion_id = banner_id
            calc.add_click(click_id, banner_id, campaign_id)
            calc.add_conversion(conversion_id, click_id, 0.5*banner_id)
        end

        ########################################################################
        # second campaign has 4 banners with conversions and two with clicks
        campaign_id = 2
        (1..4).each do |banner_id|
            click_id = banner_id + 100
            conversion_id = banner_id + 100
            calc.add_click(click_id, banner_id, campaign_id)
            calc.add_conversion(conversion_id, click_id, 0.5*banner_id)
        end
        calc.add_click(105, 5, campaign_id)
        calc.add_click(106, 6, campaign_id)
        calc.add_click(107, 6, campaign_id)

        ########################################################################
        # third campaign has no conversions and 3 banners with clicks
        campaign_id = 3
        calc.add_click(205, 4, campaign_id)
        calc.add_click(206, 5, campaign_id)
        calc.add_click(207, 5, campaign_id)
        calc.add_click(208, 6, campaign_id)
        calc.add_click(209, 6, campaign_id)
        calc.add_click(210, 6, campaign_id)

        calc.calculate

        # check first campaign
        assert_equal [11,10,9,8,7,6,5,4,3,2], calc.get_top_banner_ids(1)

        # check second campaign
        assert_equal [4,3,2,1,6], calc.get_top_banner_ids(2)

        # check third campaign
        third_banners = calc.get_top_banner_ids(3)
        assert_equal 5, third_banners.length
        assert_equal [6,5,4], third_banners.first(3)

    end
end
