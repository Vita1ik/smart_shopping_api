require 'swagger_helper'

RSpec.describe 'Api::V1::TargetAudiences', type: :request do
  path '/api/v1/target_audiences' do

    get('List all target audiences') do
      tags 'Target Audiences'
      produces 'application/json'
      security [Bearer: []]

      response(200, 'successful') do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   name: { type: :string },
                   slug: { type: :string }
                 },
                 required: ['id', 'name']
               }

        let!(:audiences) { create_list(:target_audience, 3) }
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