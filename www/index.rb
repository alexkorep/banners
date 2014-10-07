require 'sinatra'
#require 'csv'
require "redis"
require "./config/config.rb"

get '/' do
    value = Redis.current.get("mykey")
    "Hello World #{value}!"
end

error do
  'Sorry there was a nasty error - ' + env['sinatra.error'].name
end
