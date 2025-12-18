require 'swagger_helper'

RSpec.describe 'Api::V1::Searches', type: :request do
  require 'swagger_helper'

  path '/api/v1/searches' do
    get('list searches') do
      tags 'Searches'
      security [Bearer: []]
      produces 'application/json'
      description 'Returns a list of the current user\'s searches with simplified filter names.'

      response(200, 'successful') do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   price_min: { type: :integer, nullable: true },
                   price_max: { type: :integer, nullable: true },

                   # Filters now return arrays of strings (names)
                   brands: {
                     type: :array,
                     items: { type: :string }
                   },
                   sizes: {
                     type: :array,
                     items: { type: :string }
                   },
                   colors: {
                     type: :array,
                     items: { type: :string }
                   },
                   categories: {
                     type: :array,
                     items: { type: :string }
                   },
                   target_audiences: {
                     type: :array,
                     items: { type: :string }
                   }
                 },
                 required: %w[id]
               }

        run_test!
      end

      response(401, 'unauthorized') do
        run_test!
      end
    end
    
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