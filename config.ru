$LOAD_PATH << File.join(Dir.getwd, 'lib')

require 'rubygems'
require 'bundler'

Bundler.require

require 'scheduler'
require 'games'

# Configure the app
SchedulerApp.set :games, Games.new

run SchedulerApp
