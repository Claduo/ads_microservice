require 'spec_helper'

ENV['RACK_ENV'] ||= 'test'

require_relative '../config/enviroment'
abort('Pls run tests in test mode only') if Application.environment != :test

Dir[Application.root.concat('/spec/support/**/*.rb')].sort.each {|file| require file}
RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include RouteHelpers, type: :routes
end