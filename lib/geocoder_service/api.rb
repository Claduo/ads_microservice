module GeocoderService
  module Api
    def geo_coordinates(city)
      response = connection.get('/geocode/v1/', {city: city})
      response.body.dig('geo_data') if response.success?
    end
  end
end