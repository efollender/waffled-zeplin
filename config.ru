require './env' if File.exists?('env.rb')
require './server'
run Sinatra::Application