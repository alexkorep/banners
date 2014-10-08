# Structure describing the banner performance - number of clicks and
# total conversion revenue
BannerPerformance = Struct.new(:clicks, :revenue)

# Structure describing click, what campaign and banner it belings to
ClickAttr = Struct.new(:campaign_id, :banner_id)

BannerRec = Struct.new(:banner_id, :banner_performance)

class ConversionCalc
    def initialize
        # Hash keyed by campaing_id. Each element is a hash keyed by banner_id.
        # Each element is a banner performance structure BannerPerformance
        @campaigns = Hash.new{
            |hash, key| hash[key] = Hash.new {
                |hash2, key2| hash2[key2] = BannerPerformance.new(
                    clicks: 0, revenue: 0)
            }
        }

        # Hash keyed by banner_id. Each element is a click describing
        # structure, ClickAttr
        @clicks = Hash.new

        # Hash keyed by campaign_id. Each element is array of top performing
        # banner_ids
        @top_banner_ids = Hash.new
    end

    def add_banner(banner_id, campaign_id)
        @campaigns[campaign_id][banner_id] = BannerPerformance.new(0, 0)
    end

    def add_click(click_id, banner_id, campaign_id)
        @campaigns[campaign_id][banner_id].clicks += 1
        @clicks[click_id] = ClickAttr.new(campaign_id, banner_id)
    end

    def add_conversion(conversion_id, click_id, amount)
        click = @clicks[click_id]
        if click.nil?
            # TODO Report data inconsistency error. There are several options:
            # 1. Raise an exception and handle it on CVS loader's level
            # 2. Log it and/or report to the monitoring tool like NewRelic
            return
        end

        @campaigns[click.campaign_id][click.banner_id].revenue += amount
    end

    def sort_compare(a, b)
        if a.banner_performance.revenue
            return a.banner_performance.revenue > b.banner_performance.revenue
        end

        return a.banner_performance.clicks > b.banner_performance.clicks
    end

    def calculate_campaign(campaign_id, campaign)
        banners = Array.new

        campaign.each do |banner_id, banner_performance|
            banners.push(BannerRec.new(banner_id, banner_performance))
        end

        # sort by revenue descending
        banners.sort! do |a, b|
            if a.banner_performance.revenue
                b.banner_performance.revenue <=> a.banner_performance.revenue
            end

            b.banner_performance.clicks <=> a.banner_performance.clicks
        end

        first_ten_banners = banners.first(10)
        revenue_banner_count = 0
        result_banner_ids = Array.new
        first_ten_banners.each do |banner|
            if banner.banner_performance.revenue
                revenue_banner_count += 1
                result_banner_ids.push(banner.banner_id)
            end
        end

        if revenue_banner_count >= 5
            # 1. If there are more than 10 elements with revenue > 0, use these 10 elements
            # 2. If there are 5 to 9 elements with revenue > 0, use these elements
            return result_banner_ids.first(revenue_banner_count)
        else
            # 3. If there are less than 5 elements with revenue > 0, pick these
            # banners and add the next ones to have 5 in total
            return result_banner_ids.first(5)
        end
    end

    def calculate
        @campaigns.each_pair do |campaign_id, campaign|
            @top_banner_ids[campaign_id] = calculate_campaign(campaign_id,
                                                              campaign)
        end
    end

    def get_top_banner_ids(campaign_id)
        @top_banner_ids[campaign_id]
    end
end
