require "csv"

class ConversionCalc
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