module Ads
  class CreateService
    prepend BasicService

    option :ad do
      option :title
      option :description
      option :city
    end

    option :user_id

    attr_reader :ad

    def call
      @ad = ::Ad.new(@ad.to_h)
      @ad.user_id = @user_id

      if @ad.valid?
        add_geo_coordinates
        @ad.save
      else
        fail!(@ad.errors)
      end
    end

    private

    def add_geo_coordinates
      response = geocoder_client.geo_coordinates(@ad.city)
      @ad.lat = response['lat']
      @ad.lon = response['lon']
    end

    def geocoder_client
      GeocoderService::Client.new
    end
  end
end
