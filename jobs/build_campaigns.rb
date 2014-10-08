require "redis"
require "csv"
require "./config/config.rb"
require "./lib/conversion_calc.rb"

# Module to perform background task of building top banners out of scv files
# Background tasks is executed in the beginning of every 15 minutes.
#
# Since this task takes time, the new banners will not be accessible, say
# at 0:00:00, they will probably become accessible at 0:00:05.
# TODO: To fix it we can calculate these values in advance, save to a separate
#       Redis namespace and swap these namespaces at the beginning of every 15
#       minutes.
module CampaignBuilder
    @queue = :my_job_queue

    REDIS_EXPIRE_TIMEOUT = 16*60 #16 minutes

    def self.perform()
        calc = self.load_data
        calc.get_campaign_ids.each do |campaign_id|
            top_banners = calc.get_top_banner_ids(campaign_id)

            key = "campaign#{campaign_id}"
            Redis.current.set(key, top_banners.to_json)
            Redis.expire(key, REDIS_EXPIRE_TIMEOUT)
        end

        # TODO we need cleanup the campaigns which are not active anymore
        #      Now it's done by redis 16 minutes timeout, but it could lead to
        #      campaign created at 0:00 can be still accessible at 0:15
    end

    def self.get_csv_file_num
        time = Time.new
        if time.min.between?(0, 14)
            return '1'
        elsif time.min.between?(15, 29)
            return '2'
        elsif time.min.between?(30, 44)
            return '3'
        elsif time.min.between?(45, 59)
            return '4'
        end
    end

    def self.load_data
        calc = ConversionCalc.new

        csv_file_num = self.get_csv_file_num
        folder = File.dirname(__FILE__) +'/../csv/' + csv_file_num

        CSV.foreach("#{folder}/impressions_#{csv_file_num}.csv") do |row|
            banner_id = row[0]
            campaign_id = row[1]
            calc.add_impression(banner_id, campaign_id)
        end

        CSV.foreach("#{folder}/clicks_#{csv_file_num}.csv") do |row|
            click_id = row[0]
            banner_id = row[1]
            campaign_id = row[2]
            calc.add_click(click_id, banner_id, campaign_id)
        end

        CSV.foreach("#{folder}/conversions_#{csv_file_num}.csv") do |row|
            conversion_id = row[0]
            click_id = row[1]
            revenue = row[2].to_f
            calc.add_conversion(conversion_id, click_id, revenue)
        end

        calc.calculate
        return calc
    end
end