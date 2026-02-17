require 'swagger_helper'

RSpec.describe 'Budgets', type: :request do
  path '/api/budgets' do
    get 'List all budgets' do
      tags 'Budgets'
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
    before do
      allow(EventBus::Publisher).to receive(:publish).and_return(true)
    end

    post 'Approve a budget' do
      tags 'Budgets'

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
