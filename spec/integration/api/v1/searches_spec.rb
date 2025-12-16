require 'swagger_helper'

RSpec.describe 'Api::V1::Searches', type: :request do
  path '/api/v1/searches' do
    post('Create a new search and start scraping') do
      tags 'Searches'
      description 'Creates a search record and triggers a background Sidekiq job to scrape shoes.'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]

      parameter name: :Authorization,
                in: :header,
                type: :string,
                required: true,
                description: 'Bearer token'

      parameter name: :search_params, in: :body, schema: {
        type: :object,
        properties: {
          brand_ids: { type: :array, items: { type: :integer }, description: 'IDs of brands (e.g. [1, 2])' },
          size_ids: { type: :array, items: { type: :integer }, description: 'IDs of sizes' },
          category_ids: { type: :array, items: { type: :integer }, description: 'IDs of categories' },
          color_ids: { type: :array, items: { type: :integer }, description: 'IDs of colors' },
          target_audience_ids: { type: :array, items: { type: :integer }, description: 'IDs of target audiences' },
          price_min: { type: :integer, description: 'Minimum price', example: 1000 },
          price_max: { type: :integer, description: 'Maximum price', example: 5000 }
        }
      }

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 search_id: { type: :integer }
               }

        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{generate_token(user.id)}" }

        # Valid payload
        let(:search_params) do
          {
            brand_ids: [create(:brand).id],
            price_min: 1000,
            price_max: 2000
          }
        end

        # Mock Sidekiq so we don't actually try to connect to Redis during doc generation
        before do
          allow(ScrapeShoesJob).to receive(:perform_async)
        end

        run_test!
      end

      response(422, 'validation error') do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{generate_token(user.id)}" }

        # Invalid payload (Assuming price_min cannot be negative, or based on your model validation)
        # If your model has no validation, this test might fail (return 200).
        # You can force failure by mocking .save to return false if needed.
        let(:search_params) { { price_min: -100 } }

        run_test!
      end

      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid_token' }
        let(:search_params) { {} }
        run_test!
      end
    end
  end
end