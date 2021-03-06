require 'spec_helper'

RSpec.describe Search, vcr: true do
  describe 'GET /' do
    before(:each) do
      get '/'
    end

    it 'should have a response with http status ok (200)' do
      expect(last_response).to be_ok
    end
  end

  describe 'GET /search' do
    before(:each) do
      get '/search'
    end

    it 'should redirect to /search/' do
      expect(last_response).to be_redirect   # This works, but I want it to be more specific
      follow_redirect!
      expect(last_request.url).to eq('http://example.org/search/')
    end
  end

  describe 'GET /results' do
    context 'a valid search' do
      before(:each) do
        get '/results', { q: 'banana' }
      end

      it 'should have a response with http status ok (200)' do
        expect(last_response).to be_ok
      end

      it 'should contain the query parameter in the response body' do
        expect(last_response.body).to include('banana')
      end

      it 'should return the number of results' do
        expect(last_response.body).to include('About 18900 results')
      end

      it 'should return title, link and summary for each entry' do
        expect(last_response.body).to include('Trade dispute between the EU and the USA over <b>bananas</b>')
        expect(last_response.body).to include('http://researchbriefings.files.parliament.uk/documents/RP99-28/RP99-28.pdf')
        expect(last_response.body).to include('Mar 12, 1999 <b>...</b> describes why the EU import regime for <b>bananas</b> arose, ...')
      end
    end

    context 'an invalid search' do
      before(:each) do
        get '/results', { q: 'fdsfsd' }
      end

      it 'should have a response with http status ok (200)' do
        expect(last_response).to be_ok
      end

      it 'should contain no results' do
        expect(last_response.body).to include('There were no results for &ldquo;fdsfsd&rdquo;.')
      end
    end

    context 'search for a non-ascii character' do
      it 'should have a response with http status ok (200)' do
        get '/results', { q: 'Ü' }
        expect(last_response).to be_ok
      end
    end

    context 'very long query' do
      before(:each) do
        get '/results', { q: File.read('spec/fixtures/strings/long_search_string') }
      end

      it 'should cut query to maximum 2048 characters' do
        expect(WebMock).to have_requested(:get, "https://api20170418155059.azure-api.net/search/?q=#{File.read('spec/fixtures/strings/escaped_parameter_string')}&start=1")
          .with(headers: {'Accept'=>['*/*', 'application/atom+xml'], 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Ocp-Apim-Subscription-Key'=>ENV['OPENSEARCH_AUTH_TOKEN'], 'User-Agent'=>'Ruby'}).once
      end
    end
  end
end
