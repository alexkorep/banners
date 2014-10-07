task default: %w[runserver]

task :devserver do
  sh "rerun 'ruby hi.rb'"
end

task :runserver do
  ruby 'hi.rb'
end

task :test do
  ruby "tests/unittest.rb"
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

    Resque.redis = 'localhost:6379'

    Resque.schedule = YAML.load_file('config/resque_schedule.yml')

    # The only job we have so far
    require './jobs/build_campaigns.rb'
  end
end