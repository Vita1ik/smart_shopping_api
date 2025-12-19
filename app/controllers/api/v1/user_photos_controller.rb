module Api
  module V1
    class UserPhotosController < ApiController
      before_action :authenticate_user!

      def index
        photos = current_user.user_photos.with_attached_image
        render json: photos.map { |photo| photo_response(photo) }
      end

      def try_on_shoe
        original_photo = current_user.user_photos.find(params[:user_photo_id])
        shoe = Shoe.find(params[:shoe_id])

        existing_result = current_user.user_photos.find_by(
          shoe: shoe,
          source_photo: original_photo
        )

        if existing_result
          return render json: {
            success: true,
            cached: true, # Можна додати прапорець для фронтенду
            id: existing_result.id,
            shoe_id: existing_result.shoe_id,
            url: existing_result.image.url
          }, status: :ok
        end

        human_url = original_photo.image.url
        shoe_url = shoe.images.first

        generated_image_io = TryShoes.new(human_url: human_url, shoe_url: shoe_url).call

        if generated_image_io
          result_photo = current_user.user_photos.build(shoe:, source_photo: original_photo)

          result_photo.image.attach(
            io: generated_image_io,
            filename: "vton_result_#{shoe.id}_#{Time.now.to_i}.png",
            content_type: 'image/png'
          )

          if result_photo.save
            render json: {
              success: true,
              id: result_photo.id,
              shoe_id: result_photo.shoe_id,
              url: result_photo.image.url
            }, status: :created
          else
            render json: { errors: result_photo.errors.full_messages }, status: :unprocessable_entity
          end
        else
          render json: { error: "Failed to generate try-on image" }, status: :bad_request
        end
      end

      def create
        # Створюємо запис і прикріплюємо файл
        photo = current_user.user_photos.build
        photo.image.attach(params[:image])

        if photo.save
          render json: photo_response(photo), status: :created
        else
          render json: { errors: photo.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        photo = current_user.user_photos.find(params[:id])
        photo.destroy
        head :no_content
      end

      private

      # Допоміжний метод для формування JSON з URL картинки
      def photo_response(photo)
        {
          id: photo.id,
          url: photo.image.url, # Генерує посилання на файл
          shoe_id: photo.shoe_id,
          created_at: photo.created_at
        }
      end
    end
  end
end