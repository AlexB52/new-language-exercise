require "bundler/inline"
gemfile do
  gem "minitest"
  gem "sqlite3"
  gem "debug"
end

require "minitest/autorun"
require_relative 'ruby/quote_repository'

class Client
  require 'uri'
  require 'net/http'

  attr_accessor :domain
  def initialize(domain:)
    @domain = domain
  end

  def list_quotes
    get("/quotes")
  end

  def create_quote(**params)
    post("/quotes", params: params)
  end

  def delete_quote(id)
    delete("/quotes/#{id}")
  end

  def update_quote(id, params: {})
    patch("/quotes/#{id}", params: params)
  end

  def post(path, params: {})
    uri = URI("#{domain}#{path}")
    uri.query = URI.encode_www_form(params)
    request(uri) do |http|
      Net::HTTP::Post.new(uri)
    end
  end

  def get(path, params: {})
    uri = URI("#{domain}#{path}")
    request(uri) do |http|
      Net::HTTP::Get.new(uri)
    end
  end

  def delete(path)
    uri = URI("#{@domain}#{path}")
    request(uri) do |http|
      Net::HTTP::Delete.new(uri)
    end
  end

  def patch(path, params: {})
    uri = URI("#{@domain}#{path}")
    uri.query = URI.encode_www_form(params)
    request(uri) do |http|
      Net::HTTP::Patch.new(uri)
    end
  end

  private

  def request(uri)
    Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request yield
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
    domain = ENV.fetch('DOMAIN', 'http://localhost:4567')
    @client = Client.new(domain: domain)
  end

  def teardown
    list_quotes.each { |quote| delete_quote(quote.id) }
  end

  def list_quotes
    response = @client.list_quotes
    JSON.parse(response.body).map(&Quote)
  end

  def create_quote(**params)
    response = @client.create_quote(**params)
    Quote.new JSON.parse(response.body)
  end

  def update_quote(id, params:)
    @client.update_quote(id, params: params)
  end

  def delete_quote(id)
    @client.delete_quote(id)
  end

  def test_server_is_up
    response = @client.get("/")

    assert_equal "200", response.code
    assert_equal "ok", response.body
  end

  def test_full_quote_lifecycle
    assert_equal [], list_quotes

    quote = create_quote(title: 'a note', body: 'content')
    assert_equal 'a note', quote.title
    assert_equal 'content', quote.body

    assert_equal [quote], list_quotes

    delete_quote(quote.id)

    assert_equal [], list_quotes
  end
end