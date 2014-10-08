task default: %w[runserver]

task :devserver do
  sh "rerun 'ruby www/index.rb'"
end

task :runserver do
  ruby 'www/index.rb'
end

task :test do
  ruby "test/test_build_campaign.rb"
end

# Resque tasks
require 'resque/tasks'
require 'resque/scheduler/tasks'

namespace :resque do
  task :setup do
    require 'resque'
    require 'resque-scheduler'
    require 'yaml'

    ENV['QUEUE'] = '*'

    Resque.redis = ENV.fetch("REDISTOGO_URL", 'redis://localhost:6379/')

    Resque.schedule = YAML.load_file('config/resque_schedule.yml')

    # The only job we have so far
    require './jobs/build_campaigns.rb'
  end
end
