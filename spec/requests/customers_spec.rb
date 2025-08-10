require 'swagger_helper'

RSpec.describe 'Customers', type: :request do
  let(:user) { create(:user) }
  let(:token) do
    secret_key = Rails.application.credentials.jwt_secret || ENV["JWT_SECRET"]
    payload = { user_id: user.id, exp: 24.hours.from_now.to_i }
    JWT.encode(payload, secret_key, 'HS256')
  end
  let(:Authorization) { "Bearer #{token}" }

  path '/customers' do
    get 'List all customers' do
      tags 'Customers'
      security [ bearerAuth: [] ]
      produces 'application/json'

      response '200', 'customers found' do
        before { create_list(:customer, 3) }

        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              document_number: { type: :string },
              email: { type: :string },
              phone: { type: :string }
            },
            required: %w[id name document_number email phone]
          }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.size).to eq 3
        end
      end
    end

    post 'Create a new customer' do
      tags 'Customers'
      security [ bearerAuth: [] ]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :customer, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          document_number: { type: :string },
          email: { type: :string },
          phone: { type: :string }
        },
        required: %w[name document_number email phone]
      }

      response '201', 'customer created' do
        let(:customer) do
          {
            name: 'Luke Skywalker',
            document_number: '12345678900',
            email: 'luke@rebellion.com',
            phone: '555-1234'
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq('Luke Skywalker')
          expect(data['document_number']).to eq('12345678900')
        end
      end

      response '422', 'invalid request' do
        let(:customer) { { name: '' } }
        run_test!
      end
    end
  end

  path '/customers/{document_number}' do
    get 'Get customer by document number' do
      tags 'Customers'
      security [ bearerAuth: [] ]
      produces 'application/json'

      parameter name: :document_number, in: :path, type: :string, description: 'Customer document number'

      response '200', 'customer found' do
        let(:customer_record) { create(:customer) }
        let(:document_number) { customer_record.document_number }

        schema type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string },
            document_number: { type: :string },
            email: { type: :string },
            phone: { type: :string },
            vehicles: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  license_plate: { type: :string }
                },
                required: [ 'license_plate' ]
              }
            }
          },
          required: %w[id name document_number email phone vehicles]

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['document_number']).to eq(document_number)
          expect(data).to have_key('vehicles')
        end
      end

      response '404', 'customer not found' do
        let(:document_number) { 'nonexistent' }
        run_test!
      end
    end
  end

  path '/customers/{id}' do
    put 'Update customer by id' do
      tags 'Customers'
      security [ bearerAuth: [] ]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer
      parameter name: :customer, in: :body, schema: {
        type: :object,
        properties: {
          id: { type: :integer },
          name: { type: :string },
          document_number: { type: :string },
          email: { type: :string },
          phone: { type: :string }
        },
        required: %w[id name document_number email phone]
      }

      response '200', 'customer updated' do
        let(:customer_record) { create(:customer) }
        let(:id) { customer_record.id }
        let(:customer) do
          {
            id: id,
            name: 'Leia Organa',
            document_number: customer_record.document_number,
            email: 'leia@rebellion.com',
            phone: '555-4321'
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq('Leia Organa')
        end
      end

      response '422', 'invalid request' do
        let(:id) { create(:customer).id }
        let(:customer) { { id: id, name: '' } }
        run_test!
      end
    end

    delete 'Delete customer by id' do
      tags 'Customers'
      security [ bearerAuth: [] ]
      parameter name: :id, in: :path, type: :integer

      response '200', 'customer deleted' do
        let(:id) { create(:customer).id }
        run_test!
      end

      response '404', 'customer not found' do
        let(:id) { 0 }
        run_test!
      end
    end
  end

  path '/customers/{document_number}/add_vehicle' do
    post 'Add vehicle to customer' do
      tags 'Customers'
      security [ bearerAuth: [] ]
      consumes 'application/json'

      parameter name: :document_number, in: :path, type: :string
      parameter name: :vehicle, in: :body, schema: {
        type: :object,
        properties: {
          license_plate: { type: :string }
        },
        required: [ 'license_plate' ]
      }

      response '200', 'vehicle added' do
        let(:customer_record) { create(:customer) }
        let(:document_number) { customer_record.document_number }
        let(:vehicle) { { license_plate: 'ABC1234' } }

        run_test!
      end

      response '404', 'customer not found' do
        let(:document_number) { 'nonexistent' }
        let(:vehicle) { { license_plate: 'XYZ9876' } }
        run_test!
      end
    end
  end
end
