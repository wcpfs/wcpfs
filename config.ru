$LOAD_PATH << File.join(Dir.getwd, 'lib')

require 'rubygems'
require 'bundler'

Bundler.require

require 'google_api'
require 'aws-sdk'

require 'routes'
require 'games'
require 'users'
require 'mail_client'
require 'aws_client'

if ENV['AWS_ACCESS_KEY'].nil?
  puts "FATAL: Need to source .env file with API keys"
  exit 1
end

def get_env
  return nil if :production == Routes.settings.environment
  return 'test'
end

# Configure the app

puts "Starting WCPFS in environment: #{get_env}"
aws_connection = AwsClient.connect({
  region: 'us-east-1',
  access_key_id: ENV['AWS_ACCESS_KEY'],
  secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
}, get_env)

mail_client = MailClient.new get_env
games = Games.new(aws_connection, mail_client)
EM.next_tick do
  EM.add_periodic_timer 10 do
    emails = mail_client.check_mail
    if emails
      puts "Received #{emails.length} emails"
      emails.each { | email | games.on_discussion email }
    end
  end
end

Routes.set :games, games
Routes.set :google, GoogleApi.new
Routes.set :users, Users.new(aws_connection)
Routes.set :mail_client, mail_client # FIXME games and users should contain this instead

run Routes
