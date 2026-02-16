require 'swagger_helper'

RSpec.describe 'Budgets', type: :request do
  let(:user) { create(:user) }
  let(:token) do
    secret_key = Rails.application.credentials.jwt_secret || ENV["JWT_SECRET"]
    payload = { user_id: user.id, exp: 24.hours.from_now.to_i, cpf: user.document_number, iss: 'auth.local', aud: 'api.local' }
    JWT.encode(payload, secret_key, 'HS256')
  end
  let(:Authorization) { "Bearer #{token}" }

  let(:customer_payload) do
    {
      id: '123',
      email: "customer@gmail.com"
    }
  end

  let(:vehicle_payload) do
    {
      license_plate: 'XYZ-0000'
    }
  end

  before do
    allow_any_instance_of(
      Application::Customer::CustomerApplication
    ).to receive(:find_by_id).and_return(customer_payload)

    allow_any_instance_of(
      Application::Customer::VehicleApplication
    ).to receive(:find_by_id).and_return(vehicle_payload)
  end

  path '/api/budgets' do
    get 'List all budgets' do
      tags 'Budgets'
      security [ bearerAuth: [] ]
      produces 'application/json'

      response '200', 'budgets found' do
        before { create_list(:budget, 3) }

        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :string },
              date: { type: :string, format: :date },
              total_value: { type: :string },
              status: { type: :string },
              service_order: { type: :object }
            },
            required: %w[id date total_value status]
          }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.size).to eq 3
        end
      end
    end

    get 'Filtered by customer_id' do
      tags 'Budgets'
      security [ bearerAuth: [] ]
      produces 'application/json'

      parameter name: :customer_id, in: :query, type: :string, description: 'Customer customer_id to filter budgets'

      response '200', 'budgets found with filter' do
        let!(:service_order) { create(:service_order) }
        let!(:budget1) { create(:budget, service_order: service_order) }
        let!(:budget2) { create(:budget) }

        let(:customer_id) { service_order.customer_id }

        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :string },
              date: { type: :string, format: :date },
              total_value: { type: :string },
              status: { type: :string },
              service_order: { type: :object }
            },
            required: %w[id date total_value status]
          }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.size).to eq 2
          expect(data.first['id']).to eq(budget1.id)
        end
      end
    end
  end

  path '/api/budgets/{id}' do
    get 'Get budget by id' do
      tags 'Budgets'
      security [ bearerAuth: [] ]
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer, description: 'Budget ID'

      response '200', 'budget found' do
        let(:budget) { create(:budget) }
        let(:id) { budget.id }

        schema type: :object,
          properties: {
            id: { type: :string },
            date: { type: :string, format: :date },
            total_value: { type: :string },
            status: { type: :string },
            service_order: { type: :object }
          },
          required: %w[id date total_value status]

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['id']).to eq(id)
          expect(data).to have_key('status')
        end
      end

      response '404', 'budget not found' do
        let(:id) { 0 }
        run_test!
      end
    end
  end

  path '/api/budgets/{id}/approve' do
    post 'Approve a budget' do
      tags 'Budgets'
      security [ bearerAuth: [] ]

      parameter name: :id, in: :path, type: :integer, description: 'Budget ID'

      response '200', 'budget approved' do
        let(:service_order) { create(:service_order, status: 'waiting_approval') }
        let(:budget) { create(:budget, status: 'pending', service_order_id: service_order.id) }
        let(:id) { budget.id }

        run_test!
      end

      response '404', 'budget not found' do
        let(:id) { 0 }
        run_test!
      end
    end
  end

  path '/api/budgets/{id}/reject' do
    post 'Reject a budget' do
      tags 'Budgets'
      security [ bearerAuth: [] ]

      parameter name: :id, in: :path, type: :integer, description: 'Budget ID'

      response '200', 'budget rejected' do
        let(:budget) { create(:budget, status: 'pending') }
        let(:id) { budget.id }

        run_test!
      end

      response '404', 'budget not found' do
        let(:id) { 0 }
        run_test!
      end
    end
  end
end
