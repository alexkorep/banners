require 'sinatra'
#require 'csv'
require "redis"
require 'json'
require "./config/config.rb"

HISTORY_COOKIE = 'history'

get '/campaigns/:campaign_id' do
    banners_str = Redis.current.get("campaign#{params[:campaign_id]}")
    if not banners_str.is_a? String
        # Error - campaign is not found
        halt 404
    end

    banners = JSON.parse(banners_str)
    banner = pick_next_banner(banners)
    "<img src=\"/images/image_#{banner}.png\"/>"
end

not_found do
    "Your page cannot be found"
end

def pick_next_banner(banners)
    # Get banner history from cookies
    history_str = request.cookies[HISTORY_COOKIE]
    history = []
    if not history_str.nil?
        # Try to parse history from cookie
        begin
            history = JSON.parse(history_str)
        rescue JSON::ParserError => e
            history = []
        end

        # Get last N banners from the history and remove them from the banner
        # list
        history = history.last(banners.length - 1)
        history.each do |banner_id|
            banners -= [banner_id]
        end
    end

    # Pick up a random banner from the banner list
    banner = banners.sample

    # Update history
    history += [banner]
    response.set_cookie HISTORY_COOKIE, history.to_json

    return banner
end