RSpec.describe Ads::CreateService do
  subject { described_class }

  let(:user_id) { 110 }
  let(:geocoder_client) { instance_double("Geocoder Client") }

  before do
    allow(GeocoderService::Client).to receive(:new).and_return(geocoder_client)
    allow(geocoder_client).to receive(:geo_coordinates).and_return({'lat' => 100.to_f, 'lon' => 200.to_f })
  end

  context 'valid parameters' do
    let(:ad_params) do
      {
        title: 'Ad title',
        description: 'Ad description',
        city: 'City'
      }
    end

    it 'creates a new ad' do
      expect { subject.call(ad: ad_params, user_id: user_id) }
        .to change { Ad.count }.from(0).to(1)
    end

    it 'assigns ad' do
      result = subject.call(ad: ad_params, user_id: user_id)

      expect(result.ad).to be_kind_of(Ad)
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

    it 'does not create ad' do
      expect { subject.call(ad: ad_params, user_id: user_id) }
        .not_to change { Ad.count }
    end

    it 'assigns ad' do
      result = subject.call(ad: ad_params, user_id: user_id)

      expect(result.ad).to be_kind_of(Ad)
    end
  end
end
