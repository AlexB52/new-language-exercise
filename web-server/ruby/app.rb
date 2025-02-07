require "bundler/inline"

gemfile do
  source "https://rubygems.org"

  gem "sinatra"
  gem "rackup"
  gem "puma"
  gem "sqlite3"
  gem "debug"
end

require_relative 'quote_repository'

DB = SQLite3::Database.new ":memory:"

QuoteRepository.new(db: DB).delete_all

class Application < Sinatra::Base
  def initialize(*args, **kwargs, &block)
    super
    @quotes = QuoteRepository.new(db: DB)
  end

  get "/" do
    "ok"
  end

  get '/quotes' do
    @quotes.list.map(&:to_h).to_json
  end

  post '/quotes' do
    quote = @quotes.create(title: params[:title], body: params[:body])
    quote.to_json
  end

  get '/quotes/:id' do
    quote = @quotes.find(params[:id])
    quote.to_json
  end

  patch '/quotes/:id' do
    quote = @quotes.update(params[:id], title: params[:title], body: params[:body])
    quote.to_json
  end

  delete '/quotes/:id' do
    @quotes.delete(params[:id])
  end

  run!
end

