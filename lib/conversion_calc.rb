require "csv"
require 'pp'

# Structure describing the banner performance - number of clicks and
# total conversion revenue
BannerPerformance = Struct.new(:clicks, :revenue)

# Structure describing click, what campaign and banner it belings to
ClickAttr = Struct.new(:campaign_id, :banner_id)

BannerRec = Struct.new(:banner_id, :banner_performance)

class ConversionCalc
    def initialize
        #hash, key is click_id, value is banner_id
        #@banner_by_click = Hash.new

        #hash, key is click_id, value is campaign_id
        #@campaign_by_click = Hash.new

        # Hash keyed by campaing_id. Each element is a hash keyed by banner_id.
        # Each element is a banner performance structure BannerPerformance
        @campaigns = Hash.new{
            |hash, key| hash[key] = Hash.new{
                |hash2, key2| hash2[key2] = BannerPerformance.new(
                    clicks: 0, revenue: 0)
            }
        }

        # Hash keyed by banner_id. Each element is a click describing
        # structure, ClickAttr
        @clicks = Hash.new
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
            # TODO Report data inconsistency error?
            return
        end

        @campaigns[click.campaign_id][click.banner_id].revenue += amount
    end

    def sort_compare(a, b)
        puts "[#{a}, #{b}]"
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
        #banners.sort_by!{ |banner| -banner.banner_performance.revenue }
        #puts "[before: #{banners}]\n"
        banners.sort! do |a, b|
            #puts "%%%[#{a}, #{b}]%%%\n"
            if a.banner_performance.revenue
                b.banner_performance.revenue <=> a.banner_performance.revenue
            end

            b.banner_performance.clicks <=> a.banner_performance.clicks
        end
        #puts "[after: #{banners}]\n"

        # TODO look through banners array.
        # 1. If there are more than 10 elements with revenue > 0, use these 10 elements
        # 2. If there are 5 to 9 elements with revenue > 0, use these elements
        # 3. If there are less than 5 elements with revenue > 0, pick these
        # banners and add the next ones to have 5 in total
        # 4 no banners with revenue - covered by 3
    end

    def calculate
        @campaigns.each_pair do |campaign_id, campaign|
            calculate_campaign(campaign_id, campaign)
        end
    end

    def get_top_banner_ids(campaign_id)
        # TODO provide results
        [1, 2]
    end

    def self.build_campaign(clicks_filename, conversions_filename)
        # Hash, key is click_id, value is <banner_id>|<campaign_id>
        banner_by_click = Hash.new
        campaign_by_click = Hash.new
        #CSV.foreach(File.dirname(__FILE__) +'/../csv/1/clicks_1.csv') do |row|
        CSV.foreach(conversions_filename) do |row|
            click_id = row[0]
            banner_id = row[1]
            campaign_id = row[2]
            banner_by_click[click_id] = banner_id
            campaign_by_click[click_id] = campaign_id
        end

        # Total revenue for each (banner_id, campaing_id) pair
        total_revenues = Hash.new(Hash.new(0.0))
        click_counts = Hash.new(Hash.new(0))
        #CSV.foreach(File.dirname(__FILE__) +'/../csv/1/conversions_1.csv') do |row|
        CSV.foreach(clicks_filename) do |row|
            conversion_id = row[0]
            click_id = row[1]
            revenue = row[2].to_f

            banner_id = banner_by_click[click_id]
            campaign_id = campaign_by_click[click_id]
            if banner_id.nil? or campaign_id.nil?
                # TODO report data inconsistency
            elsif
                total_revenues[campaign_id][banner_id] += revenue
                click_counts[campaign_id][banner_id] += 1
            end
        end
    end
end
