require 'swagger_helper'

RSpec.describe 'Vehicles', type: :request do
  let(:user) { create(:user) }
  let(:token) do
    secret_key = Rails.application.credentials.jwt_secret || ENV["JWT_SECRET"]
    payload = { user_id: user.id, exp: 24.hours.from_now.to_i }
    JWT.encode(payload, secret_key, 'HS256')
  end
  let(:Authorization) { "Bearer #{token}" }

  path '/vehicles' do
    get 'List all vehicles' do
      tags 'Vehicles'
      security [ bearerAuth: [] ]
      produces 'application/json'

      response '200', 'vehicles found' do
        before { create_list(:vehicle, 3) }

        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              license_plate: { type: :string },
              brand: { type: :string },
              model: { type: :string },
              year: { type: :integer },
              customer_id: { type: :integer }
            },
            required: %w[id license_plate brand model year customer_id]
          }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.size).to eq 3
        end
      end
    end

    post 'Create a new vehicle' do
      tags 'Vehicles'
      security [ bearerAuth: [] ]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :vehicle, in: :body, schema: {
        type: :object,
        properties: {
          license_plate: { type: :string },
          brand: { type: :string },
          model: { type: :string },
          year: { type: :integer },
          customer_id: { type: :integer }
        },
        required: %w[license_plate brand model year customer_id]
      }

      response '201', 'vehicle created' do
        let(:vehicle) do
          {
            license_plate: 'ABC1234',
            brand: 'Toyota',
            model: 'Corolla',
            year: 2020,
            customer_id: create(:customer).id
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['license_plate']).to eq('ABC1234')
        end
      end

      response '422', 'invalid request' do
        let(:vehicle) { { license_plate: '' } }
        run_test!
      end
    end
  end

  path '/vehicles/{license_plate}' do
    get 'Get vehicle by license plate' do
      tags 'Vehicles'
      security [ bearerAuth: [] ]
      produces 'application/json'

      parameter name: :license_plate, in: :path, type: :string, description: 'Vehicle license plate'

      response '200', 'vehicle found' do
        let(:vehicle_record) { create(:vehicle) }
        let(:license_plate) { vehicle_record.license_plate }

        schema type: :object,
          properties: {
            id: { type: :integer },
            license_plate: { type: :string },
            brand: { type: :string },
            model: { type: :string },
            year: { type: :integer },
            customer_id: { type: :integer }
          },
          required: %w[id license_plate brand model year customer_id]

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['license_plate']).to eq(license_plate)
        end
      end

      response '404', 'vehicle not found' do
        let(:license_plate) { 'NONEXIST' }
        run_test!
      end
    end
  end

  path '/vehicles/{id}' do
    put 'Update vehicle by id' do
      tags 'Vehicles'
      security [ bearerAuth: [] ]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer
      parameter name: :vehicle, in: :body, schema: {
        type: :object,
        properties: {
          id: { type: :integer },
          license_plate: { type: :string },
          brand: { type: :string },
          model: { type: :string },
          year: { type: :integer },
          customer_id: { type: :integer }
        },
        required: %w[id license_plate brand model year customer_id]
      }

      response '200', 'vehicle updated' do
        let(:vehicle_record) { create(:vehicle) }
        let(:id) { vehicle_record.id }
        let(:vehicle) do
          {
            id: id,
            license_plate: vehicle_record.license_plate,
            brand: 'Honda',
            model: 'Civic',
            year: 2021,
            customer_id: vehicle_record.customer_id
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['brand']).to eq('Honda')
        end
      end

      response '422', 'invalid request' do
        let(:id) { create(:vehicle).id }
        let(:vehicle) { { id: id, brand: '' } }
        run_test!
      end
    end

    delete 'Delete vehicle by id' do
      tags 'Vehicles'
      security [ bearerAuth: [] ]
      parameter name: :id, in: :path, type: :integer

      response '200', 'vehicle deleted' do
        let(:id) { create(:vehicle).id }
        run_test!
      end

      response '404', 'vehicle not found' do
        let(:id) { 0 }
        run_test!
      end
    end
  end
end
