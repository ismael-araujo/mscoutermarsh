require 'dotenv/load'

require_relative 'tweet_to_image.rb'
require_relative 'whoop.rb'
require 'twitter'
require 'pry'
require 'octokit'

twitter = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
  config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
  config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
  config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
end

latest_tweet = twitter.user_timeline("mscccc", count: 15, exclude_replies: true, include_rts: false).first
tweet_id = latest_tweet.id
tweet_url = latest_tweet.uri.to_s

tweet_image = TweetToImage.url(tweet_id)

## Create new readme
template = File.open('README_TEMPLATE.md', 'r')
text = template.read

whoop_data = Whoop.stats

## Stars
client = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
recent_stars = client.stargazers("mscoutermarsh/mscoutermarsh", per_page: 100).map(&:login).reverse
recent_stars2 = client.stargazers("mscoutermarsh/mscoutermarsh", per_page: 100, page: 2).map(&:login).reverse
recent_stars = recent_stars + recent_stars2

f = File.new('README.md', 'w')
f.write(text.gsub("<star-count>", recent_stars.count.to_s).gsub("<tweet-image-url>", tweet_image).gsub("<tweet-url>", tweet_url).gsub("<sleep-stats>", whoop_data).gsub("<stars>", recent_stars.join(", ")))
f.close
