require 'swagger_helper'

RSpec.describe 'Api::V1::Colors', type: :request do
  path '/api/v1/colors' do

    get('List all colors') do
      tags 'Colors'
      produces 'application/json'
      security [Bearer: []]

      parameter name: :Authorization,
                in: :header,
                type: :string,
                required: true,
                description: 'Bearer token'

      response(200, 'successful') do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   name: { type: :string }
                 },
                 required: ['id', 'name']
               }

        let!(:colors) { create_list(:color, 3) }
        let(:user) { create(:user) }

        let(:Authorization) do
          payload = { user_id: user.id, exp: 24.hours.from_now.to_i }
          token = JWT.encode(payload, Rails.application.secret_key_base, 'HS256')
          "Bearer #{token}"
        end

        run_test! do |response|
          expect(JSON.parse(response.body).length).to eq(3)
        end
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid_token' }
        run_test!
      end
    end
  end
end