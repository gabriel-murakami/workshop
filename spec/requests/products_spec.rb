require 'swagger_helper'

RSpec.describe 'Product', type: :request do
  let(:user) { create(:user) }
  let(:token) do
    secret_key = Rails.application.credentials.jwt_secret || ENV["JWT_SECRET"]
    payload = { user_id: user.id, exp: 24.hours.from_now.to_i }
    JWT.encode(payload, secret_key, 'HS256')
  end
  let(:Authorization) { "Bearer #{token}" }

  path '/products' do
    get 'List all products' do
      tags 'Product'
      security [ bearerAuth: [] ]
      produces 'application/json'

      response '200', 'products found' do
        before { create_list(:product, 3) }

        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              description: { type: :string, nullable: true },
              stock_quantity: { type: :integer },
              base_price: { type: :string }
            },
            required: %w[id name stock_quantity base_price]
          }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.size).to eq 3
        end
      end
    end

    post 'Create a new product' do
      tags 'Product'
      security [ bearerAuth: [] ]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :product, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          description: { type: :string },
          stock_quantity: { type: :integer },
          base_price: { type: :string },
          sku: { type: :string }
        },
        required: %w[name stock_quantity base_price sku]
      }

      response '201', 'product created' do
        let(:product) do
          {
            name: 'Brake Pad',
            description: 'High quality brake pad',
            stock_quantity: 20,
            base_price: 120.5,
            sku: "AP777"
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq('Brake Pad')
          expect(data['stock_quantity']).to eq(20)
          expect(data['base_price']).to eq("120.5")
        end
      end

      response '422', 'invalid request' do
        let(:product) { { name: '' } }
        run_test!
      end
    end
  end

  path '/products/{id}' do
    get 'Get product by id' do
      tags 'Product'
      security [ bearerAuth: [] ]
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer, description: 'Auto part ID'

      response '200', 'product found' do
        let(:product_record) { create(:product) }
        let(:id) { product_record.id }

        schema type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string },
            description: { type: :string, nullable: true },
            stock_quantity: { type: :integer },
            base_price: { type: :string }
          },
          required: %w[id name stock_quantity base_price]

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['id']).to eq(id)
        end
      end

      response '404', 'product not found' do
        let(:id) { 0 }
        run_test!
      end
    end

    put 'Update product by id' do
      tags 'Product'
      security [ bearerAuth: [] ]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer
      parameter name: :product, in: :body, schema: {
        type: :object,
        properties: {
          id: { type: :integer },
          name: { type: :string },
          description: { type: :string },
          stock_quantity: { type: :integer },
          base_price: { type: :string }
        },
        required: %w[id name stock_quantity base_price]
      }

      response '200', 'product updated' do
        let(:product_record) { create(:product) }
        let(:id) { product_record.id }
        let(:product) do
          {
            id: id,
            name: 'Updated Brake Pad',
            description: product_record.description,
            stock_quantity: product_record.stock_quantity,
            base_price: product_record.base_price
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq('Updated Brake Pad')
        end
      end

      response '422', 'invalid request' do
        let(:id) { create(:product).id }
        let(:product) { { id: id, name: '' } }
        run_test!
      end
    end

    delete 'Delete product by id' do
      tags 'Product'
      security [ bearerAuth: [] ]
      parameter name: :id, in: :path, type: :integer

      response '200', 'product deleted' do
        let(:id) { create(:product).id }
        run_test!
      end

      response '404', 'product not found' do
        let(:id) { 0 }
        run_test!
      end
    end
  end

  path '/products/{id}/add' do
    post 'Add stock quantity to product' do
      tags 'Product'
      security [ bearerAuth: [] ]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          stock_change: { type: :integer }
        },
        required: [ 'stock_change' ]
      }

      response '200', 'stock added' do
        let(:product_record) { create(:product, stock_quantity: 10) }
        let(:id) { product_record.id }
        let(:body) { { stock_change: 5 } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['stock_quantity']).to eq(product_record.stock_quantity + 5)
        end
      end
    end
  end

  path '/products/{id}/remove' do
    post 'Remove stock quantity from product' do
      tags 'Product'
      security [ bearerAuth: [] ]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          stock_change: { type: :integer }
        },
        required: [ 'stock_change' ]
      }

      response '200', 'stock removed' do
        let(:product_record) { create(:product, stock_quantity: 10) }
        let(:id) { product_record.id }
        let(:body) { { stock_change: 3 } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['stock_quantity']).to eq(product_record.stock_quantity - 3)
        end
      end
    end
  end
end
