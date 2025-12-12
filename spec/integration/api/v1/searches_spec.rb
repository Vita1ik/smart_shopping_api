require 'swagger_helper'

RSpec.describe 'Api::V1::Searches', type: :request do
  path '/api/v1/searches' do

    post('Create a new search (Scrape products)') do
      tags 'Searches'
      description 'Initiates a scraping job based on filters and returns found products.'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]

      # Define the Input Schema (The filters)
      parameter name: :search_params, in: :body, schema: {
        type: :object,
        properties: {
          brand_ids: { type: :array, items: { type: :integer }, description: 'List of Brand IDs' },
          category_ids: { type: :array, items: { type: :integer }, description: 'List of Category IDs' },
          color_ids: { type: :array, items: { type: :integer }, description: 'List of Color IDs' },
          size_ids: { type: :array, items: { type: :integer }, description: 'List of Size IDs' },
          target_audience_ids: { type: :array, items: { type: :integer }, description: 'List of Target Audience IDs' },
          price_range: { type: :array, items: { type: :integer }, description: '[Min, Max] price', example: [1000, 5000] }
        }
      }

      # --- 200 OK: Returns Scraped Data ---
      response(200, 'successful') do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   title: { type: :string },
                   price: { type: :string },
                   link: { type: :string },
                   images: { type: :array, items: { type: :string } }
                 }
               }

        let(:user) { create(:user) }

        # 1. Generate Valid Token
        let(:Authorization) do
          payload = { user_id: user.id, exp: 24.hours.from_now.to_i }
          token = JWT.encode(payload, Rails.application.secret_key_base, 'HS256')
          "Bearer #{token}"
        end

        # 2. Define Params
        let(:search_params) do
          {
            brand_ids: [1],
            price_range: [100, 2000]
          }
        end

        # 3. MOCK THE SCRAPER (Critical Step)
        before do
          # We tell RSpec: "Whenever .run is called on the Scraper,
          # don't actually open a browser. Just return this fake array."
          allow_any_instance_of(Scrapers::Intertop::Scraper)
            .to receive(:run)
                  .and_return([
                                {
                                  title: 'Nike Air Max',
                                  price: '2500 UAH',
                                  link: 'https://intertop.ua/product',
                                  images: ['img1.jpg']
                                }
                              ])
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.length).to eq(1)
          expect(data.first['title']).to eq('Nike Air Max')
        end
      end

      # --- 422 Validation Error ---
      response(422, 'validation failed') do
        let(:user) { create(:user) }
        let(:Authorization) do
          payload = { user_id: user.id, exp: 24.hours.from_now.to_i }
          token = JWT.encode(payload, Rails.application.secret_key_base, 'HS256')
          "Bearer #{token}"
        end

        # Send invalid data (e.g. assume you add validation that at least one filter is required)
        # If your model has no validation, this test might fail (it will return 200).
        let(:search_params) { { price_range: ['invalid'] } }

        # Mock scraper to ensure it doesn't run even on failure
        before do
          allow_any_instance_of(Scrapers::Intertop::Scraper).to receive(:run).and_return([])
        end

        # Only uncomment this if you actually have validation in your Search model
        # run_test!
      end

      # --- 401 Unauthorized ---
      response(401, 'unauthorized') do
        let(:Authorization) { 'Bearer invalid_token' }
        let(:search_params) { {} }
        run_test!
      end
    end
  end
end