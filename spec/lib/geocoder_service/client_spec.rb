RSpec.describe GeocoderService::Client, type: :client do
  subject {described_class.new(connection: test_connection)}

  let(:status) { 201 }
  let(:headers) { { "Content-Type" => "application/json" } }
  let(:body) { {} }

  before do
    stubs.get("/geocode/v1/"){ [status, headers, body.to_json] }
  end

  describe "#geocode" do
    context "with known city name" do
      let(:city) {"City 17"}
      let(:body) { { "geo_data" => {"lat" => 100.to_f, "lon" => 200.to_f } } }
      it do
        expect(subject.geo_coordinates(city)).to eq({"lat" => 100.to_f, "lon" => 200.to_f})
      end
    end

    context "with unknown city name" do
      let(:city) {"City 18"}
      let(:status) { 404 }
      it do
        expect(subject.geo_coordinates(city)).to be_nil
      end
    end
  end
end