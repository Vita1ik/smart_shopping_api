require 'swagger_helper'

RSpec.describe 'Api::V1::Brands', type: :request do
  # Adjust this path if your route is different
  path '/api/v1/brands' do

    get('List all brands') do
      tags 'Brands'
      description 'Returns a list of all available brands'
      produces 'application/json'
      security [Bearer: []] # Locks the endpoint in Swagger UI

      parameter name: :Authorization,
                in: :header,
                type: :string,
                required: true,
                description: 'Bearer token'

      # Define the "List" response structure
      response(200, 'successful') do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   name: { type: :string }
                   # Add other fields from your Presenters::Base if needed
                 },
                 required: ['id', 'name']
               }

        # --- Test Data Setup ---
        # 1. Create some brands using FactoryBot
        let!(:brands) { create_list(:brand, 3) }

        # 2. Create a user for authentication
        let(:user) { create(:user) }

        # 3. Generate the Token (Using the logic we fixed earlier)
        let(:Authorization) do
          payload = { user_id: user.id, exp: 24.hours.from_now.to_i }
          token = JWT.encode(payload, Rails.application.secret_key_base, 'HS256')
          "Bearer #{token}"
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.length).to eq(3)
          expect(data.first).to have_key('name')
        end
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid_token' }
        run_test!
      end
    end
  end
end