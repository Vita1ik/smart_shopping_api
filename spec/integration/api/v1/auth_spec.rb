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
          password: { type: :string, example: '1rwjioi3#257fJ@23456' }
        },
        required: %w[email password first_name last_name]
      }

      response '201', 'user created' do
        schema type: :object,
               properties: {
                 email: { type: :string },
                 first_name: { type: :string, nullable: true },
                 last_name: { type: :string, nullable: true },
                 size: {
                   type: :object,
                   nullable: true,
                   properties: {
                     id: { type: :integer },
                     name: { type: :string }
                   }
                 },
                 target_audience: {
                   type: :object,
                   nullable: true,
                   properties: {
                     id: { type: :integer },
                     name: { type: :string }
                   }
                 }
               }
        
        let(:user) do
          { email: 'john.doe@example.com', password: '1rwjioi3#257fJ@23456', first_name: 'John', last_name: 'Doe' }
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
          password: { type: :string, example: '1rwjioi3#257fJ@23456' }
        },
        required: %w[email password]
      }

      before { create(:user, email: 'john.doe@example.com', password: '1rwjioi3#257fJ@23456') }

      response '200', 'user signed in' do
        schema type: :object,
               properties: {
                 email: { type: :string },
                 first_name: { type: :string, nullable: true },
                 last_name: { type: :string, nullable: true },
                 size: {
                   type: :object,
                   nullable: true,
                   properties: {
                     id: { type: :integer },
                     name: { type: :string }
                   }
                 },
                 target_audience: {
                   type: :object,
                   nullable: true,
                   properties: {
                     id: { type: :integer },
                     name: { type: :string }
                   }
                 }
               }
        
        let(:user) { { email: 'john.doe@example.com', password: '1rwjioi3#257fJ@23456' } }
        run_test!
      end

      response '401', 'invalid credentials' do
        let(:user) { { email: 'wrong@example.com', password: 'wrong' } }
        run_test!
      end
    end
  end
end
