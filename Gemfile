source 'https://rubygems.org'

# Use Sinatra for our web server
gem 'sinatra', '~> 2.0'
gem 'sinatra-contrib'

# Use HAML for our view rendering
gem 'haml'

# Use Puma as our web server
gem 'puma'

# Use Parliament-Ruby for web requests
gem 'parliament-ruby', '~> 0.7'

# Use Parliament-Opensearch to handle our Opensearch requests
gem 'parliament-opensearch', '~> 0.2'

# Use Pugin for front-end components and templates
gem 'pugin', '0.6.3'

# Use i18n for translations
gem 'i18n'

# Use dotenv to override environment variables
gem 'dotenv'

# Use sanitize to prevent cross site scripting
gem 'sanitize'


group :development do
  gem 'shotgun'
end

group :test do
  gem 'rake'
  gem 'capybara'
  gem 'rspec'
  gem 'simplecov', require: false
  gem 'rack-vcr'
  gem 'webmock'
  gem 'rubocop'
end
