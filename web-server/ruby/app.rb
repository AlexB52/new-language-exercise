require "bundler/inline"

gemfile do
  source "https://rubygems.org"

  gem "sinatra"
  gem "rackup"
  gem "puma"
end

require "sinatra"
require "rackup"
require "puma"

class Application < Sinatra::Base
  get "/frank-says" do
    "Put this in your pipe & smoke it!"
  end

  run!
end

