require 'pry'
require 'sinatra'
require 'json'
require_relative 'lib/entities.rb'

set :bind, '0.0.0.0'

USERNAME = 'Waff(led) Zeplin'

post '/' do
  received = JSON.parse request.body.read
  content_type :json
  response = json_response_for_slack(received)
  body response
end

post '/authorize' do
  params = JSON.parse request.body.read
  status 200
  body store_tokens(body)
end