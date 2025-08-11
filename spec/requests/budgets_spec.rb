require 'swagger_helper'

RSpec.describe 'Budgets', type: :request do
  let(:user) { create(:user) }
  let(:token) do
    secret_key = Rails.application.credentials.jwt_secret || ENV["JWT_SECRET"]
    payload = { user_id: user.id, exp: 24.hours.from_now.to_i }
    JWT.encode(payload, secret_key, 'HS256')
  end
  let(:Authorization) { "Bearer #{token}" }

  path '/budgets' do
    get 'List all budgets' do
      tags 'Budgets'
      security [ bearerAuth: [] ]
      produces 'application/json'

      # parameter name: :document_number, in: :query, type: :string, description: 'Customer document number to filter budgets'

      response '200', 'budgets found' do
        before { create_list(:budget, 3) }

        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              service_order_id: { type: :integer },
              date: { type: :string, format: :date },
              total_value: { type: :string },
              status: { type: :string }
            },
            required: %w[id service_order_id date total_value status]
          }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.size).to eq 3
        end
      end
    end

    get 'Filtered by document number' do
      tags 'Budgets'
      security [ bearerAuth: [] ]
      produces 'application/json'

      parameter name: :document_number, in: :query, type: :string, description: 'Customer document number to filter budgets'

      response '200', 'budgets found with filter' do
        let!(:customer) { create(:customer, document_number: '123.456.700-88') }
        let!(:service_order) { create(:service_order, customer: customer) }
        let!(:budget1) { create(:budget, service_order: service_order) }
        let!(:budget2) { create(:budget) }

        let(:document_number) { '123.456.700-88' }

        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              service_order_id: { type: :integer },
              date: { type: :string, format: :date },
              total_value: { type: :string },
              status: { type: :string }
            },
            required: %w[id service_order_id date total_value status]
          }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.size).to eq 1
          expect(data.first['id']).to eq(budget1.id)
        end
      end
    end
  end

  path '/budgets/{id}' do
    get 'Get budget by id' do
      tags 'Budgets'
      security [ bearerAuth: [] ]
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer, description: 'Budget ID'

      response '200', 'budget found' do
        let(:budget_record) { create(:budget) }
        let(:id) { budget_record.id }

        schema type: :object,
          properties: {
            id: { type: :integer },
            service_order_id: { type: :integer },
            date: { type: :string, format: :date },
            total_value: { type: :string },
            status: { type: :string }
          },
          required: %w[id service_order_id date total_value status]

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

  path '/budgets/{id}/approve' do
    post 'Approve a budget' do
      tags 'Budgets'
      security [ bearerAuth: [] ]

      parameter name: :id, in: :path, type: :integer, description: 'Budget ID'

      response '200', 'budget approved' do
        let(:budget_record) { create(:budget, status: 'pending') }
        let(:id) { budget_record.id }

        run_test!
      end

      response '404', 'budget not found' do
        let(:id) { 0 }
        run_test!
      end
    end
  end

  path '/budgets/{id}/reject' do
    post 'Reject a budget' do
      tags 'Budgets'
      security [ bearerAuth: [] ]

      parameter name: :id, in: :path, type: :integer, description: 'Budget ID'

      response '200', 'budget rejected' do
        let(:budget_record) { create(:budget, status: 'pending') }
        let(:id) { budget_record.id }

        run_test!
      end

      response '404', 'budget not found' do
        let(:id) { 0 }
        run_test!
      end
    end
  end
end
