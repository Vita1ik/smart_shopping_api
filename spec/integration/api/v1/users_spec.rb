require 'swagger_helper'

RSpec.describe 'Api::V1::Users', type: :request do
  # Define the path. Since it uses 'current_user', there is no {id} in the URL
  path '/api/v1/user' do
    let(:valid_token) do
      payload = { user_id: user.id, exp: 24.hours.from_now.to_i }
      JWT.encode(payload, Rails.application.secret_key_base, 'HS256')
    end

    # --- GET: Show Profile ---
    get('Get current user profile') do
      tags 'Users'
      produces 'application/json'
      security [Bearer: []] # Uses the security scheme from swagger_helper

      response(200, 'successful') do
        # Define what the JSON looks like
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

        # Setup data for the test
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{valid_token}" }
        # Or if using pure Devise without JWT in tests, you might need to mock the warden helper.

        run_test!
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid_token' }
        run_test!
      end
    end

    # --- PATCH: Update Profile ---
    patch('Update current user profile') do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]

      # Define the body parameters
      parameter name: :user_params, in: :body, schema: {
        type: :object,
        properties: {
          first_name: { type: :string },
          last_name: { type: :string },
          size_id: { type: :integer },
          target_audience_id: { type: :integer }
        }
      }

      response(200, 'successful') do
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

        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{valid_token}" }

        # The payload sent in the request
        let(:user_params) { { first_name: 'John', last_name: 'Doe' } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['first_name']).to eq('John')
        end
      end

      response(422, 'unprocessable entity') do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{valid_token}" }

        # Send invalid data (e.g. assuming size_id must exist)
        let(:user_params) { { size_id: 999999 } }

        run_test!
      end
    end
  end
end