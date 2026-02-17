require "rails_helper"

RSpec.describe Infra::Clients::CustomerServiceClient do
  let(:base_url) { "http://customer-service" }
  let(:stubs)    { Faraday::Adapter::Test::Stubs.new }

  let(:conn) do
    Faraday.new do |builder|
      builder.request :json
      builder.response :json, parser_options: { symbolize_names: true }
      builder.adapter :test, stubs
    end
  end

  subject(:client) do
    described_class.new(base_url: base_url).tap do |instance|
      instance.instance_variable_set(:@conn, conn)
    end
  end

  describe "#find_customer" do
    context "when request succeeds" do
      before do
        stubs.get("/api/customers/12345678900") do |env|
          [
            200,
            { "Content-Type" => "application/json" },
            { id: "abc-123", name: "Gabriel" }.to_json
          ]
        end
      end

      it "returns customer with indifferent access" do
        result = client.find_customer("12345678900")

        expect(result[:id]).to eq("abc-123")
        expect(result["id"]).to eq("abc-123")
        expect(result[:name]).to eq("Gabriel")
      end
    end

    context "when request fails" do
      before do
        stubs.get("/api/customers/000") do |_env|
          [
            404,
            { "Content-Type" => "application/json" },
            { error: "Not found" }.to_json
          ]
        end
      end

      it "raises ExternalServiceError" do
        expect {
          client.find_customer("000")
        }.to raise_error(Infra::Clients::ExternalServiceError) do |error|
          expect(error.status).to eq(404)
          expect(error.body).to eq({ error: "Not found" })
        end
      end
    end
  end

  describe "#vehicle_by_license_plate" do
    before do
      stubs.get("/api/vehicles/ABC1234") do |env|
        [
          200,
          { "Content-Type" => "application/json" },
          { id: "veh-1", customer_id: "abc-123" }.to_json
        ]
      end
    end

    it "returns vehicle with indifferent access" do
      result = client.vehicle_by_license_plate("ABC1234")

      expect(result[:id]).to eq("veh-1")
      expect(result["customer_id"]).to eq("abc-123")
    end
  end
end
