$LOAD_PATH.unshift File.join(__FILE__, '../lib')

require 'parliament/search'

run Rack::URLMap.new(
  '/' => Parliament::Search::Application,
  '/search/' => Parliament::Search::Application
)
