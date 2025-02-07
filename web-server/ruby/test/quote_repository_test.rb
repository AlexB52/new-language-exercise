require "bundler/inline"

gemfile do
  source "https://rubygems.org"

  gem "sqlite3"
  gem "debug"
  gem "minitest"
end

require "minitest/autorun"
require_relative '../quote_repository'

DB = SQLite3::Database.new ":memory:"

class TestQuotes < Minitest::Test
  def setup
    @db = DB
    @repo = QuoteRepository.new(db: @db)
  end

  def teardown
    @db.execute("DELETE FROM quotes;")
  end

  def assert_difference(assertion, expected)
    before = assertion.call
    yield
    assert_equal before + expected, assertion.call
  end

  def test_create_quote
    result = @repo.create(title: 'a note', body: 'content')
    assert_equal result, Quote.new(id: result.id, title: 'a note', body: 'content')
  end

  def test_count
    assert_equal 0, @repo.count
    @repo.create(title: 'a note', body: 'content')
    assert_equal 1, @repo.count
  end

  def test_delete_quote
    quote = @repo.create(title: 'a note', body: 'content')

    assert_difference -> { @repo.count }, -1 do
      @repo.delete(quote.id)
    end
  end

  def test_multiple_delete_quote
    quote = @repo.create(title: 'a note', body: 'content')

    assert_difference -> { @repo.count }, -1 do
      @repo.delete(quote.id)
    end
  end

  def test_list
    quote1 = @repo.create(title: 'Note 1')
    quote2 = @repo.create(title: 'Note 2')

    assert_equal [quote1, quote2], @repo.list

    @repo.delete(quote1.id)

    assert_equal [quote2], @repo.list
  end

  def test_find
    quote = @repo.create(title: 'Note 1')

    assert_equal quote, @repo.find(quote.id)
  end

  def test_update
    quote = @repo.create(title: 'a note', body: 'content')

    @repo.update(quote.id, title: 'a note (updated)', body: 'content (updated)')

    quote = @repo.find(quote.id)

    assert_equal 'a note (updated)', quote.title
    assert_equal 'content (updated)', quote.body
  end
end