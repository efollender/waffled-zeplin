require 'octokit'
require 'httparty'
require 'json'

client = Octokit::Client.new(:access_token => ENV['PERSONAL_TOKEN'])


def call_slack(req, params, slackdata)
  params_string = params.map { |k, v| "#{k}=#{[v].flatten.join('&')}" }.join('&')
  response = HTTParty.get('https://slack.com/api/' + req + '?' + params_string + 'token=' + slackdata)
  json = JSON.parse(response.body)
  return json
end

def json_response_for_slack(params)
  challenge = params['challenge']
  if challenge
    return challenge
  end
  bot = params['event']['bot_id']
  return if bot.nil?
  text = params['event']['attachments'][0]['text']
  pretext = params['event']['attachments'][0]['pretext']
  if is_zeplin? bot and is_issue? text
    link = get_link(pretext)
    issue = create_issue(text, link)
  end
  valid = is_issue? text
  response = {
    :repo => ENV['REPO'],
    :issue => issue,
    :bot => bot,
    :text => text,
    :is_issue => valid,
    :client => client.inspect
  }
  return response.to_json
end

def create_issue(title, link)
  return client.create_issue(ENV['REPO'], title, link)
end

def store_tokens(params)
  puts params
end

def is_zeplin?(user_id)
  return user_id === ENV['BOT_ID']
end

def is_issue?(text)
  return text.downcase().include? ENV['TRIGGER'].downcase()
end

def get_link(text)
  link_begin = text.index('https')
  link_end = text.index('|', link_begin)
  link = text[link_begin...link_end]
  return link
end