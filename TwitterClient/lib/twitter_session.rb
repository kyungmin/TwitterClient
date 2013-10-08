require 'launchy'
require 'oauth'
require 'singleton'
require 'yaml'

class TwitterSession
  include Singleton
  attr_reader :access_token

  CONSUMER_KEY = "BAleiIDXVo7zG8uju4g9Lg"
  CONSUMER_SECRET = "UHu3qCj8Qs1O8eLJPa9eKQGKPfgwEiMCfWElX0q5w"
  CONSUMER = OAuth::Consumer.new(
    CONSUMER_KEY, CONSUMER_SECRET, :site => "https://twitter.com")

  def initialize(token_file = 'lib/token_file.yml')
    @access_token = read_or_request_access_token(token_file)
  end

  def self.get(*args)
    self.instance.access_token.get(*args)
  end

  def self.post
    self.instance.access_token.post(*args)
  end

  protected
  def read_or_request_access_token(token_file)

    if File.exist?(token_file)
      File.open(token_file) { |f| YAML.load(f) }

    else
      request_token = CONSUMER.get_request_token
      authorize_url = request_token.authorize_url
      puts "Go to this URL: #{authorize_url}"
      Launchy.open(authorize_url)

      puts "Login, and type your verification code in"
      oauth_verifier = gets.chomp

      access_token = request_token.get_access_token(:oauth_verifier => oauth_verifier)
      File.open(token_file, "w") { |f| YAML.dump(access_token, f) }

      access_token
    end
  end

end