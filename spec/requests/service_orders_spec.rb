require 'swagger_helper'

RSpec.describe 'Service Orders', type: :request do
  path '/service_orders' do
    get 'returns all service orders' do
      tags 'Service Orders'
      security [ bearerAuth: [] ]
      produces 'application/json'

      response '200', 'success' do
        let(:user) { create(:user, email: "test@example.com", password: "password123", password_confirmation: "password123") }
        let(:token) do
          secret_key = Rails.application.credentials.jwt_secret || ENV["JWT_SECRET"]
          payload = { user_id: user.id, exp: 24.hours.from_now.to_i }
          JWT.encode(payload, secret_key, "HS256")
        end
        let(:Authorization) { "Bearer #{token}" }

        before { create_list(:service_order, 3) }

        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              customer_id: { type: :integer },
              vehicle_id: { type: :integer },
              service_started_at: { type: :string, format: 'date-time' },
              service_finished_at: { type: :string, format: 'date-time', nullable: true },
              status: { type: :string },
              description: { type: :string, nullable: true },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: %w[id customer_id vehicle_id status created_at updated_at]
          }

        run_test! do |response|
          expect(JSON.parse(response.body).size).to eq 3
        end
      end
    end
  end
end
