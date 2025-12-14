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

      let(:code) { 'code8329031%83' }
      let(:state) { 'state381u31091' }

      parameter name: :code, in: :query, type: :string, description: 'Authorization code from Google'
      parameter name: :state, in: :query, type: :string, description: 'State parameter'

      response '200', 'Successfully authenticated' do
        schema type: :object,
               properties: {
                 token: { type: :string },
                 exp: { type: :integer },
                 user: {
                   type: :object,
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
                 }
               }

        before do
          OmniAuth.config.test_mode = true

          # 1. Create the fake data
          auth_hash = OmniAuth::AuthHash.new({
            provider: 'google_oauth2',
            uid: '123456789',
            info: {
              email: 'test@example.com',
              first_name: 'John',
              last_name: 'Doe'
            }
          })

          # 2. Register it with OmniAuth
          OmniAuth.config.mock_auth[:google_oauth2] = auth_hash

          # 3. CRITICAL: Inject it into the Rails request environment
          # Rswag doesn't pass through the middleware the same way browser does,
          # so we force the environment to have the data.
          Rails.application.env_config['omniauth.auth'] = auth_hash
        end

        run_test!
      end

      response '302', 'Authentication failed (Redirects to failure endpoint)' do
        before do
          OmniAuth.config.test_mode = true
          # Simulate a failure condition
          OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials
          Rails.application.env_config['omniauth.auth'] = nil
        end

        run_test!
      end

      # Додайте це окремим блоком path, на рівні з іншими
      path '/auth/failure' do
        get 'OAuth Failure Endpoint' do
          tags 'Authentication'
          produces 'application/json'

          response '401', 'Returns error message' do
            schema type: :object, properties: { error: { type: :string } }
            run_test!
          end
        end
      end
    end
  end
end
