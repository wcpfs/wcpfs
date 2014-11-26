# A sample Guardfile
# More info at https://github.com/guard/guard#readme

# Note: The cmd option is now required due to the increasing number of ways
#       rspec may be run, below are examples of the most common uses.
#  * bundler: 'bundle exec rspec'
#  * bundler binstubs: 'bin/rspec'
#  * spring: 'bin/rsspec' (This will use spring if running and you have
#                          installed the spring binstubs per the docs)
#  * zeus: 'zeus rspec' (requires the server to be started separetly)
#  * 'just' rspec: 'rspec'

guard :rspec, cmd: 'bundle exec rspec --color' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec" }
  watch('spec/spec_helper.rb')  { "spec" }
  watch(/mail_templates\/(.+)\.html/)  { "spec" }
end

guard 'livereload' do
  watch(%r{lib/assets/.+\.js})
  watch(%r{public/index.html})
  watch(%r{spec/javascripts/.+\.js})
  # Rails Assets Pipeline
end

guard 'shell' do
  watch(%r{^lib/assets/(.*)\.js$}) { 
    `find lib/assets -name *.js | ctags -L-`
  }
end

guard :bundler do
  watch('Gemfile')
end
