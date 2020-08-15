module Ads
  class CreateService
    prepend BasicService

    option :ad do
      option :title
      option :description
      option :city
    end

    option :user_id
    option :geocoder_service, default: proc { GeocoderService::RpcClient.new }
    option :geocoder_http_service, default: proc { GeocoderService::Client.new }

    attr_reader :ad

    def call
      @ad = ::Ad.new(@ad.to_h)
      @ad.user_id = @user_id

      if @ad.valid?
        @ad.save
        add_geo_coordinates
      else
        fail!(@ad.errors)
      end
    end

    private

    def add_geo_coordinates(sync_request: false)
      if sync_request
        geo_coordinates_http
      else
        geo_coordinates_rpc
      end
    end

    def geo_coordinates_http
      response = geocoder_http_service.geo_coordinates(@ad.city)
      Ads::UpdateService.call(@ad.id, lat: response['lat'], lon: response['lon'])
    end

    def geo_coordinates_rpc
      @geocoder_service.geocode_later(@ad)
    end
  end
end
