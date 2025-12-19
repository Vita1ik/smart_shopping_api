require 'swagger_helper'

RSpec.describe 'Api::V1::UserPhotos', type: :request do
  # Визначаємо шлях до контролера
  path '/api/v1/user_photos' do
    # ------------------------------------------------------------------
    # GET: Отримати список фото
    # ------------------------------------------------------------------
    get('list user_photos') do
      tags 'User Photos'
      produces 'application/json'
      security [Bearer: []] # Якщо використовуєте JWT/Bearer auth

      response(200, 'successful') do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   url: { type: :string },
                   shoe_id: { type: :integer },
                   created_at: { type: :string, format: :date_time }
                 },
                 required: %w[id url]
               }

        run_test!
      end

      response(401, 'unauthorized') do
        run_test!
      end
    end

    # ------------------------------------------------------------------
    # POST: Завантажити нове фото (Multipart)
    # ------------------------------------------------------------------
    post('create user_photo') do
      tags 'User Photos'
      consumes 'multipart/form-data'
      produces 'application/json'
      security [Bearer: []]

      parameter name: :search_params, in: :formData, schema: {
        type: :object,
        properties: {
          image: { type: :file, description: 'Image file to upload' },
        }
      }


          response(201, 'created') do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 url: { type: :string },
                 created_at: { type: :string, format: :date_time }
               },
               required: %w[id url]

        run_test!
      end

      response(422, 'unprocessable entity') do
        run_test!
      end
    end
  end

  # ------------------------------------------------------------------
  # DELETE: Видалити фото
  # ------------------------------------------------------------------
  path '/api/v1/user_photos/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    delete('delete user_photo') do
      tags 'User Photos'
      security [Bearer: []]

      response(204, 'no content') do
        run_test!
      end

      response(404, 'not found') do
        run_test!
      end
    end
  end

  # ------------------------------------------------------------------
  # POST: Virtual Try-On (Примірка)
  # Маршрут: /api/v1/user_photos/:user_photo_id/try_on_shoe
  # ------------------------------------------------------------------
  path '/api/v1/user_photos/{user_photo_id}/try_on_shoe' do
    parameter name: 'user_photo_id', in: :path, type: :string, description: 'ID of the user photo to use as a model'

    post('try_on_shoe') do
      tags 'User Photos'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          shoe_id: { type: :integer, description: 'ID of the shoe to try on' }
        },
        required: %w[shoe_id]
      }

      response(201, 'image generated successfully') do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 id: { type: :integer, description: 'ID of the new generated photo' },
                 shoe_id: { type: :integer },
                 url: { type: :string, description: 'URL of the generated result' }
               },
               required: %w[success id url]

        run_test!
      end

      response(400, 'bad request / failed to generate') do
        schema type: :object,
               properties: {
                 error: { type: :string }
               }
        run_test!
      end

      response(404, 'resource not found') do
        schema type: :object,
               properties: {
                 error: { type: :string }
               }
        run_test!
      end

      response(422, 'unprocessable entity') do
        run_test!
      end
    end
  end
end