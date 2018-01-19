require 'pry'
require 'sinatra'
require 'json'
require_relative 'lib/entities.rb'

set :bind, '0.0.0.0'

USERNAME = 'Waff(led) Zeplin'

post '/' do
  body = JSON.parse request.body.read
  content_type :json
  json_response_for_slack(body)
end

post '/authorize' do
  params = JSON.parse request.body.read
  status 200
  body store_tokens(body)
end

