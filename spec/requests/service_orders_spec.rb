require 'swagger_helper'

RSpec.describe 'Service Orders', type: :request do
  let(:user) { create(:user) }
  let(:token) do
    secret_key = Rails.application.credentials.jwt_secret || ENV["JWT_SECRET"] || "test_secret"
    payload = { user_id: user.id, exp: 24.hours.from_now.to_i }
    JWT.encode(payload, secret_key, "HS256")
  end
  let(:Authorization) { "Bearer #{token}" }

  path '/service_orders/{id}' do
    get 'Get a service order by ID' do
      tags 'Service Orders'
      security [ bearerAuth: [] ]
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer, required: true

      response '200', 'service order found' do
        let(:service_order) { create(:service_order) }
        let(:id) { service_order.id }

        schema type: :object,
          properties: {
            id: { type: :integer },
            customer_id: { type: :integer },
            vehicle_id: { type: :integer },
            status: { type: :string },
            description: { type: :string, nullable: true },
            service_started_at: { type: :string, format: 'date-time', nullable: true },
            service_finished_at: { type: :string, format: 'date-time', nullable: true },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' },
            service_order_items: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  quantity: { type: :integer },
                  total_value: { type: :string },
                  item_type: { type: :string },
                  item_id: { type: :integer }
                },
                required: %w[id quantity total_value item_type item_id]
              }
            }
          },
          required: %w[id customer_id vehicle_id status created_at updated_at service_order_items]

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['id']).to eq(service_order.id)
          expect(json).to have_key('service_order_items')
        end
      end

      response '404', 'service order not found' do
        let(:id) { 0 }
        run_test!
      end
    end
  end

  path '/service_orders/{id}/send_to_diagnosis' do
    post 'Send service order to diagnosis' do
      tags 'Service Orders'
      security [ bearerAuth: [] ]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer, required: true

      response '200', 'service order sent to diagnosis' do
        let(:service_order) { create(:service_order, status: 'received') }
        let(:id) { service_order.id }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['status']).to eq('diagnosis')
          expect(json['id']).to eq(service_order.id)
        end
      end

      response '404', 'service order not found' do
        let(:id) { 0 }
        run_test!
      end
    end
  end

  path '/service_orders/{id}/send_to_approval' do
    post 'Send service order to waiting approval' do
      tags 'Service Orders'
      security [ bearerAuth: [] ]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer, required: true

      response '200', 'service order sent to waiting approval' do
        let(:service_order) { create(:service_order, status: 'diagnosis') }
        let(:id) { service_order.id }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['status']).to eq('waiting_approval')
          expect(json['id']).to eq(service_order.id)
        end
      end

      response '404', 'service order not found' do
        let(:id) { 0 }
        run_test!
      end
    end
  end

  path '/service_orders' do
    get 'List all service orders' do
      tags 'Service Orders'
      security [ bearerAuth: [] ]
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
              service_started_at: { type: :string, format: 'date-time', nullable: true },
              service_finished_at: { type: :string, format: 'date-time', nullable: true },
              status: { type: :string },
              description: { type: :string, nullable: true },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: %w[id customer_id vehicle_id status created_at updated_at]
          }

        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body).to be_an(Array)
          expect(body.size).to eq(3)
        end
      end
    end
  end

  path '/service_orders/{id}/add_services' do
    post 'Add services to a service order' do
      tags 'Service Orders'
      security [ bearerAuth: [] ]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer, required: true
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          services_codes: { type: :array, items: { type: :string, pattern: '^SVC.*' } }
        },
        required: [ 'services_codes' ]
      }

      response '200', 'services added' do
        let(:service1) { create(:service) }
        let(:service2) { create(:service) }

        let(:service_order) { create(:service_order, status: 'diagnosis') }
        let(:id) { service_order.id }
        let(:body) { { services_codes: [ service1.code, service2.code ] } }

        run_test!
      end

      response '422', 'invalid services' do
        let(:service_order) { create(:service_order, status: 'diagnosis') }
        let(:id) { service_order.id }
        let(:body) { { services_codes: [ 'SVC111', 'SVC222' ] } }

        run_test!
      end
    end
  end

  path '/service_orders/{id}/add_products' do
    post 'Add products to a service order' do
      tags 'Service Orders'
      security [ bearerAuth: [] ]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer, required: true
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          products_params: {
            type: :array,
            items: {
              type: :object,
              properties: {
                sku: { type: :string, pattern: '^AP.*' },
                quantity: { type: :integer }
              },
              required: %w[sku quantity]
            }
          }
        },
        required: [ 'products_params' ]
      }

      response '200', 'products added' do
        let(:product) { create(:product) }
        let(:service_order) { create(:service_order, status: 'diagnosis') }
        let(:id) { service_order.id }
        let(:body) { { products_params: [ { sku: product.sku, quantity: 2 } ] } }

        run_test!
      end

      response '422', 'invalid products' do
        let(:service_order) { create(:service_order) }
        let(:id) { service_order.id }
        let(:body) { { products_params: [ { sku: 'AP000', quantity: 2 } ] } }

        run_test!
      end
    end
  end

  path '/service_orders/{id}/start' do
    post 'Start a service order' do
      tags 'Service Orders'
      security [ bearerAuth: [] ]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer, required: true
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          id: { type: :integer }
        },
        required: [ 'id' ]
      }

      response '200', 'service order started' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            customer_id: { type: :integer },
            vehicle_id: { type: :integer },
            service_started_at: { type: :string, format: 'date-time', nullable: true },
            service_finished_at: { type: :string, format: 'date-time', nullable: true },
            status: { type: :string },
            description: { type: :string, nullable: true },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          },
          required: %w[id customer_id vehicle_id status created_at updated_at]

        let(:service_order) { create(:service_order, status: 'approved') }
        let(:id) { service_order.id }
        let(:body) { { id: service_order.id } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['id']).to eq(service_order.id)
          expect(json['status']).to eq('in_progress')
        end
      end
    end
  end

  path '/service_orders/{id}/finish' do
    post 'Finish a service order' do
      tags 'Service Orders'
      security [ bearerAuth: [] ]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer, required: true

      response '200', 'service order finished' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            customer_id: { type: :integer },
            vehicle_id: { type: :integer },
            service_started_at: { type: :string, format: 'date-time', nullable: true },
            service_finished_at: { type: :string, format: 'date-time', nullable: true },
            status: { type: :string },
            description: { type: :string, nullable: true },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          },
          required: %w[id customer_id vehicle_id status created_at updated_at]

        let!(:metric) { create(:metric) }
        let(:service_order) { create(:service_order, status: 'in_progress') }
        let(:id) { service_order.id }
        let(:body) { { id: service_order.id } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['id']).to eq(service_order.id)
          expect(json['status']).to eq('finished')
        end
      end
    end
  end

  path '/service_orders' do
    post 'Create a new service order' do
      tags 'Service Orders'
      security [ bearerAuth: [] ]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :service_order, in: :body, schema: {
        type: :object,
        properties: {
          customer_id: { type: :integer },
          vehicle_id: { type: :integer }
        },
        required: [ 'customer_id', 'vehicle_id' ]
      }

      response '201', 'service order created' do
        let(:customer) { create(:customer) }
        let(:vehicle) { create(:vehicle, customer: customer) }
        let(:service_order) { { customer_id: customer.id, vehicle_id: vehicle.id } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['customer_id']).to eq(customer.id)
          expect(json['vehicle_id']).to eq(vehicle.id)
          expect(json['id']).to be_present
        end
      end

      response '422', 'invalid request' do
        let(:service_order) { { customer_id: nil, vehicle_id: nil } }
        run_test!
      end
    end
  end
end
