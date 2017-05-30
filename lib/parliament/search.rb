Bundler.setup(:default, ENV['RACK_ENV'] || 'development')

GC::Profiler.enable

require 'parliament'

module Parliament
  module Search
    autoload :VERSION, 'parliament/search/version'
    autoload :Application, 'parliament/search/application'

    require 'dotenv'
  end
end
