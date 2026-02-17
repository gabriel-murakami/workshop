require 'swagger_helper'

RSpec.describe 'Metrics', type: :request do
  path '/api/metrics' do
    get 'List all metrics' do
      tags 'Metrics'
      produces 'application/json'

      response '200', 'metrics found' do
        before { create_list(:metric, 3) }

        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :string },
              service_order_count: { type: :integer },
              average_time: { type: :number },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: %w[id service_order_count average_time created_at updated_at]
          }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.size).to eq 3
        end
      end
    end
  end
end
