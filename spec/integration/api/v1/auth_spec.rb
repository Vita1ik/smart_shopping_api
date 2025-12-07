# spec/integration/api/v1/auth_spec.rb
require 'swagger_helper'
require 'rails_helper'

RSpec.describe 'Authentication API', type: :request do
  path '/api/v1/sign_up' do
    post 'Sign up a user' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: 'john.doe@example.com' },
          password: { type: :string, example: '123456' },
          first_name: { type: :string, example: 'John' },
          last_name: { type: :string, example: 'Doe' }
        },
        required: %w[email password first_name last_name]
      }

      response '201', 'user created' do
        let(:user) do
          { email: 'john.doe@example.com', password: '123456', first_name: 'John', last_name: 'Doe' }
        end
        run_test!
      end

      response '422', 'invalid request' do
        let(:user) { { email: 'invalid' } }
        run_test!
      end
    end
  end

  path '/api/v1/sign_in' do
    post 'Sign in a user' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: 'john.doe@example.com' },
          password: { type: :string, example: '123456' }
        },
        required: %w[email password]
      }

      before { User.create(email: 'john.doe@example.com', password: '123456') }

      response '200', 'user signed in' do
        let(:user) { { email: 'john.doe@example.com', password: '123456' } }
        run_test!
      end

      response '401', 'invalid credentials' do
        let(:user) { { email: 'wrong@example.com', password: 'wrong' } }
        run_test!
      end
    end
  end
end
