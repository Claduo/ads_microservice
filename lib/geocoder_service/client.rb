require 'dry/initializer'
require_relative 'api'

module GeocoderService
  class Client
    extend Dry::Initializer[undefined: false]
    include Api

    option :url, default: proc { Settings.app.geocoder_base_url }
    option :connection, default: proc { build_connection }

    private

    def build_connection
      Faraday.new(@url) do |connection|
        connection.use ErrorsMiddleware
        connection.request :json
        connection.response :json, content_type: /\bjson$/
        connection.adapter Faraday.default_adapter
        connection.headers["X_REQUEST_ID"] = Thread.current[:request_id]
      end
    end
  end

  class ErrorsMiddleware < Faraday::Response::Middleware
  end
end