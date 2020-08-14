RSpec.describe AdRoutes, type: :routes do
  describe 'GET /' do
    let(:user_id) { 110 }

    before do
      create_list(:ad, 3, user_id: user_id)
    end

    it 'returns a collection of ads' do
      get '/v1'

      expect(last_response.status).to eq(200)
      expect(response_body['data'].size).to eq(3)
    end
  end

  describe 'POST /v1 ' do
    let(:user_id) { 110 }
    let(:geocoder_client) { instance_double("Geocoder Client") }

    before do
      allow(GeocoderService::Client).to receive(:new).and_return(geocoder_client)
      allow(geocoder_client).to receive(:geo_coordinates).and_return({'lat' => 100.to_f, 'lon' => 200.to_f })
    end

    context 'missing parameters' do
      it 'returns an error' do
        post '/v1'
        expect(last_response.status).to eq(422)
      end
    end

    context 'invalid parameters' do
      let(:ad_params) do
        {
            title: 'Ad title',
            description: 'Ad description',
            city: ''
        }
      end

      it 'returns an error' do
        post '/v1', ad: ad_params, user_id: user_id

        expect(last_response.status).to eq(422)
        expect(response_body['errors']).to include(
                                               {
                                                   'detail' => 'Enter city',
                                                   'source' => {
                                                       'pointer' => '/data/attributes/city'
                                                   }
                                               }
                                           )
      end
    end

    context 'valid parameters' do
      let(:ad_params) do
        {
            title: 'Ad title',
            description: 'Ad description',
            city: 'City'
        }
      end

      let(:last_ad) { Ad.last }

      it 'creates a new ad' do
        expect { post '/v1', ad: ad_params, user_id: user_id }
            .to change { Ad.count }.from(0).to(1)

        expect(last_response.status).to eq(201)
      end

      it 'returns an ad' do
        post '/v1', ad: ad_params, user_id: user_id

        expect(response_body['data']).to a_hash_including(
                                             'id' => last_ad.id.to_s,
                                             'type' => 'ad'
                                         )
      end
    end
  end
end
