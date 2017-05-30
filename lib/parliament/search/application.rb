# Sinatra Base Classes
require 'sinatra'
require 'sinatra/namespace'
require 'sinatra/content_for'

# Pugin components for view
require 'pugin'

# Require Parliament-Ruby gems
require 'parliament/open_search'

# Require helper classes
require 'parliament/search/helpers'

# Require translations
require 'i18n'
require 'i18n/backend/fallbacks'
require 'sanitize'

module Parliament
  module Search
    class Application < Sinatra::Base
      helpers Sinatra::ContentFor
      helpers Parliament::Search::Helpers::PaginationHelper

      # Register snatra modules
      register Sinatra::Namespace
      register Parliament::Search::Helpers::MultiView

      # Setup global view options
      set :view_paths, [ './views/', Pugin.views_path ]
      set :view_options, { :layout => '/pugin/layouts/pugin-sinatra' }

      # Enable logging
      configure do
        enable :logging
      end

      # Setup Parliament Opensearch
      begin
        Parliament::Request::OpenSearchRequest.description_url = ENV['OPENSEARCH_DESCRIPTION_URL']
      rescue Errno::ECONNREFUSED => e
        raise StandardError, "There was an error getting the description file from OPENSEARCH_DESCRIPTION_URL environment variable value: '#{ENV['OPENSEARCH_DESCRIPTION_URL']}' - #{e.message}"
      end

      before do
        uri = request.path

        if uri && uri[-8..-1] == '/search/' && env['PATH_INFO'] == '/'
          puts 'Redirecting to remove a trailing slash'
          redirect uri[0...-1]
        end
      end

      get '/' do
        @query_parameter = params[:q] || nil

        # Show the index page if there is no query passed
        return show 'search/index' unless @query_parameter

        # Escape @query_parameter that replaces all 'unsafe' characters with a UTF-8 hexcode which is safer to use when making an OpenSearch request
        @query_parameter = Sanitize.fragment(@query_parameter, Sanitize::Config::RELAXED)
        @escaped_query_parameter = CGI.escape(@query_parameter)[0, 2048]
        @start_page = params[:start_page] || Parliament::Request::OpenSearchRequest.open_search_parameters[:start_page]
        @start_page = @start_page.to_i
        @count = Parliament::Request::OpenSearchRequest.open_search_parameters[:count]

        p ENV['OPENSEARCH_AUTH_TOKEN']
        request = Parliament::Request::OpenSearchRequest.new(headers: { 'Accept' => 'application/atom+xml',
                                                                        'Ocp-Apim-Subscription-Key' => ENV['OPENSEARCH_AUTH_TOKEN']},
                                                             builder: Parliament::Builder::OpenSearchResponseBuilder)

        begin
          logger.info "Making a query for '#{@query_parameter}' => '#{@escaped_query_parameter}' using the base_url: '#{request.base_url}'"
          @results = request.get({ query: @escaped_query_parameter, start_page: @start_page })
          @results.entries.each { |result| result.summary.gsub!(/<br>/, '') }

          @results_total = @results.totalResults

          show 'search/results'
        rescue Parliament::ServerError => e
          logger.warn "Server error caught from search request: #{e.message}"
          show 'search/no_results'
        end
      end

      run! if app_file == $PROGRAM_NAME
    end
  end
end
