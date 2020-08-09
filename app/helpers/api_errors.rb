require 'sinatra/extension'

module ApiErrors
  extend Sinatra::Extension

  helpers do
    def error_response(error_messages, status_code)
      errors = case error_messages
               when Sequel::Model
                 ErrorSerializer.from_model(error_messages)
               else
                 ErrorSerializer.from_messages(error_messages)
               end
      status status_code
      json errors
    end
  end

  error Sequel::NoMatchingRow do
    error_response(I18n.t(:not_found, scope: 'api.errors'), 404)
  end

  error Sequel::UniqueConstraintViolation do
    error_response(I18n.t(:not_unique, scope: 'api.errors'), 422)
  end

  error Validations::InvalidParams, KeyError do
    error_response(I18n.t(:missing_parameters, scope: 'api.errors'), 422)
  end


end
