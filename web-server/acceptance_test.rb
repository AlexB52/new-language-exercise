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

  def create_note(**params)
    post("/quotes", params: params)
  end

  def post(path, params:)
    uri = URI("#{domain}#{path}")
    Net::HTTP.start(uri.hostname, uri.port) do |http|
      uri.query = URI.encode_www_form(params)
      req = Net::HTTP::Post.new(uri)
      http.request(req)
    end
  end

  def get(path)
    uri = URI("#{domain}#{path}")
    Net::HTTP.start(uri.hostname, uri.port) do |http|
      req = Net::HTTP::Get.new(uri)
      http.request(req)
    end
  end
end

class TestQuotes < Minitest::Test
  require 'json'

  Quote = Struct.new(:id, :title, :body, keyword_init: true) do
    def self.to_proc
      ->(attributes) { new(attributes) }
    end

    def ==(other)
      other.is_a?(Quote) && id == other.id
    end
  end

  def setup
    domain = ENV.fetch('DOMAIN', 'http://localhost:4567')
    @db = SQLite3::Database.new "test.sqlite"
    @client = Client.new(domain: domain)
    @repo = QuoteRepository.new(db: @db)
  end

  def teardown
    @repo.delete_all
  end

  def test_server_is_up
    response = @client.get("/")

    assert_equal "200", response.code
    assert_equal "ok", response.body
  end

  def test_full_quote_lifecycle
    response = @client.list_quotes
    assert_equal [], JSON.parse(response.body)

    response = @client.create_note(title: 'a note', body: 'content')
    quote = Quote.new JSON.parse(response.body)
    assert_equal Quote.new(id: quote.id, title: 'a note', body: 'content'), quote

    response = @client.list_quotes
    assert_equal [quote], JSON.parse(response.body).map(&Quote)
  end
end