require_relative '../../spec_helper'

RSpec.describe Parliament::Search::Application, vcr: true do

  it 'should be a class' do
    expect(Parliament::Search::Application).to be_a(Class)
  end

  it 'should have the ContentFor helper' do
    expect(Parliament::Search::Application::Sinatra::ContentFor).not_to be(nil)
  end

  it 'should have the PaginationHelper helper' do
    expect(Parliament::Search::Application::Parliament::Search::Helpers::PaginationHelper).not_to be(nil)
  end

  it 'should register the sinatra Namespace module' do
    expect(Parliament::Search::Application::Sinatra::Namespace).not_to be(nil)
  end

  it 'should register the sinatra MultiView module' do
    expect(Parliament::Search::Application::Parliament::Search::Helpers::MultiView).not_to be(nil)
  end

  it 'should set up the global view paths' do
    expect(Parliament::Search::Application.view_paths).to eq([ './views/', Pugin.views_path ])
  end

  it 'should set up the global view options' do
    expect(Parliament::Search::Application.view_options).to eq({ :layout => '/pugin/layouts/pugin-sinatra' })
  end

  it 'should enable logging' do
    expect(Parliament::Search::Application.logging).to be(true)
  end

  context 'setting up Parliament Opensearch with a connection refused error' do
    before(:each) do
      allow(Parliament::Request::OpenSearchRequest).to receive(:description_url=).and_raise(Errno::ECONNREFUSED)
    end

    it 'should raise an error' do
      expect {
        Rack::Builder.new do
          eval File.read('../../../config.ru')
        end
      }.to raise_error(StandardError)
    end
  end

  context 'making GET requests' do

    describe 'GET /' do
      before(:each) do
        get '/'
      end

      context 'with no query' do
        it 'should have a response with http status ok (200)' do
          expect(last_response).to be_ok
        end
      end


      context 'with a query' do
        context 'a valid search' do
          before(:each) do
            get '/', { q: 'banana' }
          end

          it 'should have a response with http status ok (200)' do
            expect(last_response).to be_ok
          end

          it 'should contain the query parameter in the response body' do
            expect(last_response.body).to include('banana')
          end

          it 'should return the number of results' do
            expect(last_response.body).to include('About')
            expect(last_response.body).to include('results')
          end

          it 'should return title, link and summary for each entry' do
            expect(last_response.body).to include('Trade dispute between the EU and the USA over <b>bananas</b>')
            expect(last_response.body).to include('http://researchbriefings.files.parliament.uk/documents/RP99-28/RP99-28.pdf')
            expect(last_response.body).to include('Mar 12, 1999')
          end
        end

        context 'an invalid search' do
          before(:each) do
            get '/', { q: 'fdsfsd' }
          end

          it 'should have a response with http status ok (200)' do
            expect(last_response).to be_ok
          end

          it 'should contain no results' do
            expect(last_response.body).to include('There are no results for your search.')
          end
        end

        context 'search for a non-ascii character' do
          it 'should have a response with http status ok (200)' do
            get '/', { q: 'Ü' }
            expect(last_response).to be_ok
          end
        end

        context 'very long query' do
          before(:each) do
            get '/', { q: File.read('spec/fixtures/strings/long_search_string') }
          end

          it 'should cut query to maximum 2048 characters' do
            expect(WebMock).to have_requested(:get, "https://api20170418155059.azure-api.net/search/?q=#{File.read('spec/fixtures/strings/escaped_parameter_string')}&start=1")
            .with(headers: {'Accept'=>['*/*', 'application/atom+xml'], 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Ocp-Apim-Subscription-Key'=>ENV['OPENSEARCH_AUTH_TOKEN'], 'User-Agent'=>'Ruby'}).once
          end
        end
      end

      context '<br> tag in search results' do
        before(:each) do
          get '/results', { q: 'banana' }
        end

        it 'should strip <br> tag' do
          expect(last_response.body).not_to include('<br>')
        end
      end
    end

    context 'prevents xss on search' do

     before(:each) do
       get '/', { q: '<script>alert(document.cookie)</script>'}
     end

     it 'should prevent xss on search' do
       expect(last_response.body).not_to include('<script>alert(document.cookie)</script>')
     end

     it 'should sanitize the search term' do
       expect(last_response.body).to include('alert(document.cookie)')
     end


   end


  end

end
