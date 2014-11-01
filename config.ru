$LOAD_PATH << File.join(Dir.getwd, 'lib')

require 'rubygems'
require 'bundler'

Bundler.require

require 'scheduler'
run SchedulerApp
