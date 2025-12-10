require 'swagger_helper'

RSpec.describe 'Google OAuth API', type: :request do
  path '/auth/google_oauth2' do
    get 'Initiate Google OAuth login' do
      tags 'Authentication'
      produces 'application/json'

      response '302', 'Redirects to Google login page' do
        run_test!
      end
    end
  end
  
  path '/auth/google_oauth2/callback' do
    get 'Callback from Google OAuth' do
      tags 'Authentication'
      produces 'application/json'

      parameter name: :code, in: :query, type: :string, description: 'Authorization code from Google'
      parameter name: :state, in: :query, type: :string, description: 'State parameter'

      response '200', 'Successfully authenticated' do
        schema type: :object,
               properties: {
                 token: { type: :string },
                 user: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     name: { type: :string },
                     email: { type: :string }
                   },
                   required: ['id', 'name', 'email']
                 }
               },
               required: ['token', 'user']

        run_test!
      end

      response '401', 'Authentication failed' do
        run_test!
      end
    end
  end
end
