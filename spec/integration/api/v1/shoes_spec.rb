require 'swagger_helper'

RSpec.describe 'Api::V1::Shoes', type: :request do
  path '/api/v1/shoes' do
    get('List shoes found by a specific search') do
      tags 'Shoes'
      description 'Returns the list of shoes scraped during a specific search session.'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]

      parameter name: :search_id,
                in: :query,
                type: :integer,
                description: 'The ID of the search to retrieve results for',
                required: true

      response(200, 'successful') do
        # 👇 Updated Schema based on your Presenter
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   name: { type: :string },
                   price: { type: :integer },
                   images: { type: :array, items: { type: :string } }
                 },
                 required: ['id', 'name', 'price', 'images']
               }

        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{generate_token(user.id)}" }

        # Create Search and Shoe
        let(:search) { create(:search, user: user) }
        let(:shoe) { create(:shoe, name: 'Nike Air', price: 2500) }

        # Link them (assuming Many-to-Many via searches_shoes table)
        before { search.shoes << shoe }

        let(:search_id) { search.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          # Verify specific fields from your Presenter
          expect(data.first['name']).to eq('Nike Air')
          expect(data.first['price']).to eq(2500)
          expect(data.first).to have_key('images')
        end
      end
    end
  end
end