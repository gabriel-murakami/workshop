require 'swagger_helper'

RSpec.describe 'Authentication', type: :request do
  path '/login' do
    post 'User login and receives JWT token' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, format: :email, example: 'admin@admin.com' },
          password: { type: :string, example: 'password123' }
        },
        required: [ 'email', 'password' ]
      }

      response '200', 'JWT token returned' do
        let(:user) { create(:user, email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }
        let(:credentials) { { email: user.email, password: 'password123' } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('token')
          expect(data['token']).to be_a(String)
        end
      end

      response '401', 'invalid credentials' do
        let(:credentials) { { email: 'wrong@example.com', password: 'badpass' } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['error']).to eq('Invalid email or password')
        end
      end
    end
  end
end
