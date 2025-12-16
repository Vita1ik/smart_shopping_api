require 'swagger_helper'

RSpec.describe 'Api::V1::Shoes', type: :request do
  path '/api/v1/shoes' do
    get('List shoes found by a specific search') do
      tags 'Shoes'
      description 'Returns the list of shoes scraped during a specific search session.'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]

      parameter name: :Authorization,
                in: :header,
                type: :string,
                required: true,
                description: 'Bearer token'
      parameter name: :search_id,
                in: :query,
                type: :integer,
                description: 'The ID of the search to retrieve results for',
                required: true

      response(200, 'successful') do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   name: { type: :string },
                   product_url: { type: :string },
                   price: { type: :integer },
                   images: { type: :array, items: { type: :string } }
                 },
                 required: ['id', 'name', 'price', 'images', 'product_url']
               }

        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{generate_token(user.id)}" }
        let(:request_headers) { { 'Authorization' => "Bearer #{generate_token(user.id)}" } }

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

  path '/api/v1/shoes/{shoe_id}/like' do
    post('Like a shoe') do
      tags 'Shoes'
      description 'Mark a shoe as liked and schedule price monitoring.'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]

      parameter name: :Authorization,
                in: :header,
                type: :string,
                required: true,
                description: 'Bearer token'

      # Changed from Body to Path parameter
      parameter name: :shoe_id,
                in: :path,
                type: :integer,
                required: true,
                description: 'ID of the shoe to like'

      let(:user) { create(:user) }
      let(:Authorization) { "Bearer #{generate_token(user.id)}" }
      let(:shoe) { create(:shoe) }
      let!(:user_shoe) { create(:user_shoe, user: user, shoe: shoe) }

      # rswag uses the variable name to fill the path parameter
      let(:shoe_id) { shoe.id }

      response(200, 'liked successfully') do
        # Schema kept as Array based on your previous code
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   name: { type: :string },
                   product_url: { type: :string },
                   price: { type: :integer },
                   images: { type: :array, items: { type: :string } }
                 },
                 required: ['id', 'name', 'price', 'images', 'product_url']
               }

        run_test! do
          expect(user_shoe.reload.liked?).to be_truthy
        end
      end

      response(404, 'shoe not found') do
        let(:shoe_id) { 999999 }
        run_test!
      end
    end
  end

  # 3. DISLIKE A SHOE (Updated to use Path Parameter)
  path '/api/v1/shoes/{shoe_id}/dislike' do
    post('Dislike a shoe') do
      tags 'Shoes'
      description 'Remove like from a shoe.'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]

      parameter name: :Authorization,
                in: :header,
                type: :string,
                required: true,
                description: 'Bearer token'

      # Changed from Body to Path parameter
      parameter name: :shoe_id,
                in: :path,
                type: :integer,
                required: true,
                description: 'ID of the shoe to dislike'

      let(:user) { create(:user) }
      let(:Authorization) { "Bearer #{generate_token(user.id)}" }
      let(:shoe) { create(:shoe) }
      let!(:user_shoe) { create(:user_shoe, user: user, shoe: shoe, liked: true) }

      # rswag uses the variable name to fill the path parameter
      let(:shoe_id) { shoe.id }

      response(200, 'disliked successfully') do
        # Schema kept as Array based on your previous code
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   name: { type: :string },
                   product_url: { type: :string },
                   price: { type: :integer },
                   images: { type: :array, items: { type: :string } }
                 },
                 required: ['id', 'name', 'price', 'images', 'product_url']
               }

        run_test! do
          expect(user_shoe.reload.liked?).to be_falsey
        end
      end

      response(404, 'shoe not found') do
        let(:shoe_id) { 999999 }
        run_test!
      end
    end
  end

  path '/api/v1/shoes/liked' do
    get('List liked shoes') do
      tags 'Shoes'
      description 'Returns list of shoes liked by the current user with price details.'
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
                   name: { type: :string },
                   product_url: { type: :string },
                   price: { type: :integer },
                   images: { type: :array, items: { type: :string } },
                   current_price: { type: :integer, nullable: true },
                   prev_price: { type: :integer, nullable: true },
                   discounted: { type: :boolean }
                 },
                 required: ['id', 'name', 'price', 'images', 'product_url', 'current_price', 'discounted']
               }

        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{generate_token(user.id)}" }
        let(:shoe) { create(:shoe, name: 'Adidas Yeezy', price: 5000) }

        # Створюємо лайкнутий запис із цінами
        let!(:user_shoe) do
          create(:user_shoe,
                 user: user,
                 shoe: shoe,
                 liked: true,
                 discounted: true,
                 current_price: 4500,
                 prev_price: 5000)
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          item = data.first

          expect(item['name']).to eq('Adidas Yeezy')
          expect(item['current_price']).to eq(4500)
          expect(item['prev_price']).to eq(5000)
        end
      end
    end
  end
end