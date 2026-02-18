require 'swagger_helper'

RSpec.describe 'Service Orders', type: :request do
  let(:customer_id) { Faker::Internet.uuid }
  let(:vehicle_id) { Faker::Internet.uuid }

  before do
    client_double = instance_double(Infra::Clients::CustomerServiceClient)

    allow(Infra::Clients::CustomerServiceClient)
      .to receive(:new)
      .and_return(client_double)

    allow(client_double)
      .to receive(:find_customer)
      .with("12345678900")
      .and_return({ id: customer_id })

    allow(client_double)
      .to receive(:vehicle_by_license_plate)
      .with("ABC1234")
      .and_return({ id: vehicle_id, customer_id: customer_id })
  end

  path '/api/service_orders/{id}' do
    get 'Get a service order by ID' do
      tags 'Service Orders'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer, required: true

      response '200', 'service order found' do
        let(:service_order) { create(:service_order) }
        let(:id) { service_order.id }

        schema type: :object,
          properties: {
            id: { type: :string },
            customer_id: { type: :string },
            vehicle_id: { type: :string },
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
                  id: { type: :string },
                  quantity: { type: :integer },
                  total_value: { type: :string },
                  item_kind: { type: :string },
                  item_id: { type: :string }
                },
                required: %w[id quantity total_value item_kind item_id]
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

  path '/api/service_orders/{id}/send_to_diagnosis' do
    post 'Send service order to diagnosis' do
      tags 'Service Orders'
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

  path '/api/service_orders/{id}/send_to_approval' do
    post 'Send service order to waiting approval' do
      tags 'Service Orders'
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

  path '/api/service_orders' do
    get 'List all service orders' do
      tags 'Service Orders'
      produces 'application/json'

      response '200', 'success' do
        before { create_list(:service_order, 3) }

        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :string },
              customer_id: { type: :string },
              vehicle_id: { type: :string },
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

  path '/api/service_orders/{id}/add_services' do
    post 'Add services to a service order' do
      tags 'Service Orders'
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

  path '/api/service_orders/{id}/add_products' do
    post 'Add products to a service order' do
      tags 'Service Orders'
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

  path '/api/service_orders/{id}/start' do
    post 'Start a service order' do
      tags 'Service Orders'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer, required: true
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          id: { type: :string }
        },
        required: [ 'id' ]
      }

      response '200', 'service order started' do
        schema type: :object,
          properties: {
            id: { type: :string },
            customer_id: { type: :string },
            vehicle_id: { type: :string },
            service_started_at: { type: :string, format: 'date-time', nullable: true },
            service_finished_at: { type: :string, format: 'date-time', nullable: true },
            status: { type: :string },
            description: { type: :string, nullable: true },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          },
          required: %w[id customer_id vehicle_id status created_at updated_at]

        let(:service_order) { create(:service_order, status: 'payment_approved') }
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

  path '/api/service_orders/{id}/finish' do
    post 'Finish a service order' do
      tags 'Service Orders'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer, required: true

      response '200', 'service order finished' do
        schema type: :object,
          properties: {
            id: { type: :string },
            customer_id: { type: :string },
            vehicle_id: { type: :string },
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

  path '/api/service_orders/open' do
    post 'Open (create) a service order with full details' do
      tags 'Service Orders'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          document_number: { type: :string },
          license_plate: { type: :string },
          services_codes: {
            type: :array,
            items: { type: :string, pattern: '^SVC.*' }
          },
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
        required: %w[document_number license_plate services_codes products_params]
      }

      response '201', 'service order opened successfully' do
        let(:service1) { create(:service) }
        let(:service2) { create(:service) }
        let(:product)  { create(:product) }

        let(:body) do
          {
            document_number: "12345678900",
            license_plate: "ABC1234",
            services_codes: [ service1.code, service2.code ],
            products_params: [
              { sku: product.sku, quantity: 2 }
            ]
          }
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['id']).to be_present
          expect(json['customer_id']).to eq(customer_id)
          expect(json['vehicle_id']).to eq(vehicle_id)
          expect(json['service_order_items']).to be_an(Array)
          expect(json['service_order_items'].size).to eq(3)
        end
      end

      response '422', 'invalid parameters' do
        let(:body) do
          {
            document_number: nil,
            license_plate: nil,
            services_codes: [],
            products_params: []
          }
        end

        run_test!
      end
    end
  end
end
