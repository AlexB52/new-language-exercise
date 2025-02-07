unless ENV['DOMAIN']
  raise ArgumentError, <<~MESSAGE
    must provide DOMAIN environment variable
    ex: DOMAIN="http://localhost:4567" ruby acceptance_test.rb
  MESSAGE
end

require "bundler/inline"

gemfile do
  gem "minitest"
  gem "sqlite3"
  gem "debug"
end

require "minitest/autorun"

class Client
  require 'uri'
  require 'net/http'

  attr_accessor :domain
  def initialize(domain:)
    @domain = domain
  end

  def post(path, params: {})
    uri = URI("#{domain}#{path}")
    uri.query = URI.encode_www_form(params)
    request(uri, Net::HTTP::Post.new(uri))
  end

  def get(path, params: {})
    uri = URI("#{domain}#{path}")
    request(uri, Net::HTTP::Get.new(uri))
  end

  def delete(path)
    uri = URI("#{@domain}#{path}")
    request(uri, Net::HTTP::Delete.new(uri))
  end

  def patch(path, params: {})
    uri = URI("#{@domain}#{path}")
    uri.query = URI.encode_www_form(params)
    request(uri, Net::HTTP::Patch.new(uri))
  end

  private

  def request(uri, action)
    Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request action
    end
  end
end

class TestQuotes < Minitest::Test
  require 'json'

  Quote = Struct.new(:id, :title, :body, keyword_init: true) do
    def self.to_proc
      ->(attributes) { new(attributes) }
    end
  end

  def setup
    domain = ENV.fetch('DOMAIN')
    @client = Client.new(domain: domain)
  end

  def teardown
    list_quotes.each { |quote| delete_quote(quote.id) }
  end

  def list_quotes
    response = @client.get("/quotes")
    JSON.parse(response.body).map(&Quote)
  end

  def create_quote(**params)
    response = @client.post("/quotes", params: params)
    Quote.new JSON.parse(response.body)
  end

  def update_quote(id, **params)
    response = @client.patch("/quotes/#{id}", params: params)
    Quote.new JSON.parse(response.body)
  end

  def delete_quote(id)
    @client.delete("/quotes/#{id}")
  end

  def find_quote(id)
    response = @client.get("/quotes/#{id}")
    Quote.new JSON.parse(response.body)
  end

  def test_server_is_up
    response = @client.get("/")

    assert_equal "200", response.code
    assert_equal "ok", response.body
  end

  def test_full_quote_lifecycle
    quote = create_quote(title: 'a note', body: 'content')

    assert_equal 'a note', quote.title
    assert_equal 'content', quote.body

    assert_includes list_quotes, quote

    quote = find_quote(quote.id)

    assert_equal 'a note', quote.title
    assert_equal 'content', quote.body

    quote = update_quote(quote.id, title: 'a note (updated)', body: 'content (updated)')

    assert_equal 'a note (updated)', quote.title
    assert_equal 'content (updated)', quote.body

    quote = find_quote(quote.id)

    assert_equal 'a note (updated)', quote.title
    assert_equal 'content (updated)', quote.body

    delete_quote(quote.id)

    refute_includes list_quotes, quote
  end
end