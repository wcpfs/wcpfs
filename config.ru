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

# Configure the app

aws_client = Aws::DynamoDB::Client.new({
  :region => 'us-east-1',
  access_key_id: ENV['AWS_ACCESS_KEY'],
  secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
})
SchedulerApp.set :google, GoogleApi.new
SchedulerApp.set :games, Games.new(aws_client, ENV["GAMES_TABLE_NAME"] || 'wcpfs-games-test')
SchedulerApp.set :users, Users.new(aws_client, 'wcpfs-users')
SchedulerApp.set :mail_client, MailClient.new


run SchedulerApp
