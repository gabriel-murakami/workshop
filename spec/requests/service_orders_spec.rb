require 'swagger_helper'

RSpec.describe 'Service Orders', type: :request do
  let(:user) { create(:user) }
  let(:token) do
    secret_key = Rails.application.credentials.jwt_secret || ENV["JWT_SECRET"] || "test_secret"
    payload = { user_id: user.id, exp: 24.hours.from_now.to_i }
    JWT.encode(payload, secret_key, "HS256")
  end
  let(:Authorization) { "Bearer #{token}" }

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
        let(:service_order) { create(:service_order) }
        let(:id) { service_order.id }
        let(:body) { { services_codes: [ 'SVC001', 'SVC002' ] } }

        run_test!
      end
    end
  end

  path '/service_orders/{id}/add_auto_parts' do
    post 'Add auto parts to a service order' do
      tags 'Service Orders'
      security [ bearerAuth: [] ]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer, required: true
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          auto_parts_params: {
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
        required: [ 'auto_parts_params' ]
      }

      response '200', 'auto parts added' do
        let(:service_order) { create(:service_order) }
        let(:id) { service_order.id }
        let(:body) { { auto_parts_params: [ { sku: 'AP001', quantity: 2 } ] } }

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

        let(:service_order) { create(:service_order, status: 'awaiting_approval') }
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
end
