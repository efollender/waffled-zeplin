require 'octokit'
require 'httparty'
require 'json'

$client = Octokit::Client.new(:login => ENV['GITHUB_LOGIN'], :password => ENV['PERSONAL_TOKEN'])


def call_slack(req, params, slackdata)
  params_string = params.map { |k, v| "#{k}=#{[v].flatten.join('&')}" }.join('&')
  response = HTTParty.get('https://slack.com/api/' + req + '?' + params_string + 'token=' + slackdata)
  json = JSON.parse(response.body)
  return json
end

def is_design(text)
  return text.downcase().include? ENV['DESIGN_TRIGGER'].downcase()
end

def is_other(text)
  return text.downcase().include? ENV['TRIGGER'].downcase()
end

def create_issue(title, link)
  formatted_link = '[View in Zeplin](#{link})' + 
  if is_design(title)
    return $client.create_issue(ENV['REPO'], title, formatted_link, {:labels => 'design'})
  else
    return $client.create_issue(ENV['REPO'], title, formatted_link, {:labels => 'zeplin,ui,frontend'})
  end
end

def store_tokens(params)
  puts params
end

def is_zeplin(user_id)
  return user_id.downcase() === ENV['BOT_ID'].downcase()
end

def is_issue(text)
  return is_design(text) || is_other(text)
end

def get_link(text)
  link_begin = text.index('https')
  link_end = text.index('|', link_begin)
  link = text[link_begin...link_end]
  return link
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
  zeplin = is_zeplin(bot)
  valid = is_issue(text)
  response = {
    :zeplin => zeplin,
    :valid => valid,
    :sent => bot,
    :env => ENV['BOT_ID']
  }
  if zeplin and valid
    link = get_link(pretext)
    issue = create_issue(text, link)
    response = {
      :repo => ENV['REPO'],
      :client => $client.user.login,
      :issue => issue,
      :bot => bot,
      :text => text,
      :link => link,
    }
  end
  return response.to_json
end