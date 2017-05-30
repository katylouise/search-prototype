require 'spec_helper'

RSpec.describe 'config.ru' do
  def app
    Rack::Builder.new do
      eval File.read(File.join(File.dirname(__FILE__), '..', 'config.ru'))
    end
  end

  it 'redirects /search/ to /search' do
    get '/search/'
    expect(last_response).to be_redirect
    follow_redirect!
    expect(last_response).to be_ok
    expect(last_request.url).to eq 'http://example.org/search'
  end

  it 'does not redirect /search to /search/' do
    get '/search'
    expect(last_response).not_to be_redirect
    expect(last_request.url).to eq 'http://example.org/search'
  end

end
