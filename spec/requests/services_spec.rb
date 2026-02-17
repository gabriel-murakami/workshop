require 'swagger_helper'

RSpec.describe 'Services', type: :request do
  path '/api/services' do
    get 'List all services' do
      tags 'Services'
      produces 'application/json'

      response '200', 'services found' do
        before { create_list(:service, 3) }

        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :string },
              name: { type: :string },
              description: { type: :string, nullable: true },
              base_price: { type: :string }
            },
            required: %w[id name base_price]
          }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.size).to eq 3
        end
      end
    end

    post 'Create a new service' do
      tags 'Services'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :service, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          description: { type: :string },
          base_price: { type: :string },
          code: { type: :string }
        },
        required: %w[name base_price code]
      }

      response '201', 'service created' do
        let(:service) do
          {
            name: 'Oil Change',
            description: 'Full synthetic oil change',
            base_price: 99.99,
            code: "SVC007"
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq('Oil Change')
          expect(data['base_price']).to eq("99.99")
        end
      end

      response '422', 'invalid request' do
        let(:service) { { name: '' } }
        run_test!
      end
    end
  end

  path '/api/services/{id}' do
    get 'Get service by id' do
      tags 'Services'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer, description: 'Service ID'

      response '200', 'service found' do
        let(:service_record) { create(:service) }
        let(:id) { service_record.id }

        schema type: :object,
          properties: {
            id: { type: :string },
            name: { type: :string },
            description: { type: :string, nullable: true },
            base_price: { type: :string }
          },
          required: %w[id name base_price]

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['id']).to eq(id)
        end
      end

      response '404', 'service not found' do
        let(:id) { 0 }
        run_test!
      end
    end

    put 'Update service by id' do
      tags 'Services'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer
      parameter name: :service, in: :body, schema: {
        type: :object,
        properties: {
          id: { type: :string },
          name: { type: :string },
          description: { type: :string },
          base_price: { type: :string }
        },
        required: %w[id name base_price]
      }

      response '200', 'service updated' do
        let(:service_record) { create(:service) }
        let(:id) { service_record.id }
        let(:service) do
          {
            id: id,
            name: 'Premium Oil Change',
            description: service_record.description,
            base_price: service_record.base_price
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq('Premium Oil Change')
        end
      end

      response '422', 'invalid request' do
        let(:id) { create(:service).id }
        let(:service) { { id: id, name: '' } }
        run_test!
      end
    end

    delete 'Delete service by id' do
      tags 'Services'
      parameter name: :id, in: :path, type: :integer

      response '200', 'service deleted' do
        let(:id) { create(:service).id }
        run_test!
      end

      response '404', 'service not found' do
        let(:id) { 0 }
        run_test!
      end
    end
  end
end
