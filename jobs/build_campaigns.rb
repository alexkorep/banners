require "redis"
require "csv"
require "./config/config.rb"
require "./lib/conversion_calc.rb"

module CampaignBuilder
    def self.perform()
        calc = self.load_data
        calc.get_campaign_ids.each do |campaign_id|
            top_banners = calc.get_top_banner_ids(campaign_id)
            Redis.current.set("campaign#{campaign_id}", top_banners.to_json)
            #puts "Processed #{campaign_id}, top banners: #{top_banners}"
        end
    end

    def self.load_data
        calc = ConversionCalc.new

        CSV.foreach(File.dirname(__FILE__) +'/../csv/1/impressions_1.csv') do |row|
            banner_id = row[0]
            campaign_id = row[1]
            calc.add_impression(banner_id, campaign_id)
        end

        CSV.foreach(File.dirname(__FILE__) +'/../csv/1/clicks_1.csv') do |row|
            click_id = row[0]
            banner_id = row[1]
            campaign_id = row[2]
            calc.add_click(click_id, banner_id, campaign_id)
        end

        CSV.foreach(File.dirname(__FILE__) +'/../csv/1/conversions_1.csv') do |row|
            conversion_id = row[0]
            click_id = row[1]
            revenue = row[2].to_f
            calc.add_conversion(conversion_id, click_id, revenue)
        end

        calc.calculate
        return calc
    end

end