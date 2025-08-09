require 'swagger_helper'

RSpec.describe 'Service Orders', type: :request do
  path '/service_orders' do
    get 'returns all service orders' do
      tags 'Service Orders'
      produces 'application/json'

      response '200', 'success' do
        before { create_list(:service_order, 3) }

      schema type: :array,
        items: {
          type: :object,
          properties: {
            id: { type: :integer },
            customer_id: { type: :integer },
            vehicle_id: { type: :integer },
            opening_date: { type: :string, format: 'date-time' },
            closing_date: { type: :string, format: 'date-time', nullable: true },
            status: { type: :string },
            description: { type: :string, nullable: true },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          },
          required: %w[id customer_id vehicle_id opening_date status created_at updated_at]
        }

        run_test! do |response|
          expect(JSON.parse(response.body).size).to eq 3
        end
      end
    end
  end
end
