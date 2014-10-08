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

    # Add banner impression. Actually just creates banner performance record
    # for given banner and campaign
    # Warning: please don't call this method after add_click or add_conversion
    # since it can overwrite existing banner performance data
    def add_impression(banner_id, campaign_id)
        @campaigns[campaign_id][banner_id] = BannerPerformance.new(0, 0)
    end

    def add_click(click_id, banner_id, campaign_id)
        # TODO what if @campaigns[campaign_id][banner_id] doesn't exist?
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

    # Calculate top banners for provided campaign
    # +campaign_id+:: id of campaign
    # +campaign+:: campaign object, hash keyed by banner id with
    #              BannerPerformance as values
    # Algorithm complexity: O(N*lnN) where N is number of banners in campaign
    # (based on sort algorithm complexity)
    def calculate_campaign(campaign_id, campaign)
        banners = Array.new

        campaign.each do |banner_id, banner_performance|
            banners.push(BannerRec.new(banner_id, banner_performance))
        end

        # sort by revenue descending
        # TODO since we only need to find maximum 10 top-performing banners,
        # we can increase performance by finding them without sorting,
        # which would give O(N) time complexity instead of O(N*lnN)
        banners.sort! do |a, b|
            if a.banner_performance.revenue > 0
                b.banner_performance.revenue <=> a.banner_performance.revenue
            else
                b.banner_performance.clicks <=> a.banner_performance.clicks
            end
        end

        first_ten_banners = banners.first(10)
        revenue_banner_count = 0
        result_banner_ids = Array.new
        first_ten_banners.each do |banner|
            if banner.banner_performance.revenue > 0
                revenue_banner_count += 1
            end
            result_banner_ids.push(banner.banner_id)
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

    # Find top-performing banners for all campaigns
    # Time complexity: O(M*N*lnN) where M - number of campaigns,
    # N - number of banners in campaign
    # M*N is equal to the number of records in impressions.csv
    def calculate
        @campaigns.each_pair do |campaign_id, campaign|
            @top_banner_ids[campaign_id] = calculate_campaign(campaign_id,
                                                              campaign)
        end
    end

    # Return top-performing banners for the given campaign
    def get_top_banner_ids(campaign_id)
        @top_banner_ids[campaign_id]
    end
end
