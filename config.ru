$LOAD_PATH << File.join(Dir.getwd, 'lib')

require 'rubygems'
require 'bundler'

Bundler.require

require 'google_api'
require 'aws-sdk'

require 'scheduler'
require 'games'
require 'users'
require 'mail_client'
require 'aws_client'

if ENV['AWS_ACCESS_KEY'].nil?
  puts "FATAL: Need to source .env file with API keys"
  exit 1
end

def get_env
  return nil if 'production' == SchedulerApp.settings.environment
  return 'test'
end

# Configure the app

puts "Starting WCPFS in environment: #{get_env}"
aws_connection = AwsClient.connect({
  :region => 'us-east-1',
  access_key_id: ENV['AWS_ACCESS_KEY'],
  secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
}, get_env)

SchedulerApp.set :google, GoogleApi.new
SchedulerApp.set :games, Games.new(aws_connection)
SchedulerApp.set :users, Users.new(aws_connection)
SchedulerApp.set :mail_client, MailClient.new(get_env)

run SchedulerApp
