$LOAD_PATH << File.join(Dir.getwd, 'lib')

require 'rubygems'
require 'bundler'

Bundler.require

require 'scheduler'
require 'games'
require 'google_api'

# Configure the app

SchedulerApp.set :google, GoogleApi.new
SchedulerApp.set :games, Games.new

run SchedulerApp
