require "faraday"
require "json"
require "base64"
require "googleauth"
require "tempfile"
require "open-uri"

class TryShoes
  MODEL_ID = "virtual-try-on-preview-08-04"
  PROJECT_ID = 'smart-shopping-api'
  REGION     = 'us-central1'

  def initialize(human_url:, shoe_url:)
    @human_url = human_url
    @shoe_url  = shoe_url
  end

  def call
    puts "🚀 Starting Google Virtual Try-On..."

    response = connection.post do |req|
      req.headers = headers
      req.body = payload.to_json
    end

    if response.success?
      handle_success(response)
    else
      handle_error(response)
    end
  rescue StandardError => e
    puts "❌ EXCEPTION: #{e.message}"
    puts e.backtrace.first(5)
  end

  private

  def connection
    endpoint = "https://#{REGION}-aiplatform.googleapis.com/v1/projects/#{PROJECT_ID}/locations/#{REGION}/publishers/google/models/#{MODEL_ID}:predict"

    Faraday.new(url: endpoint) do |f|
      f.options.timeout = 180 # VTON може думати довше (до 3хв)
      f.adapter Faraday.default_adapter
    end
  end

  def headers
    {
      "Authorization" => "Bearer #{fetch_access_token}",
      "Content-Type"  => "application/json; charset=utf-8"
    }
  end

  def fetch_access_token
    scopes = ['https://www.googleapis.com/auth/cloud-platform']
    if ENV["GOOGLE_CREDENTIALS_JSON"].present?
      require "stringio" # На всяк випадок

      # Перетворюємо рядок JSON у Хеш
      creds_hash = JSON.parse(ENV["GOOGLE_CREDENTIALS_JSON"])

      # Створюємо авторизатор з хешу (без файлів!)
      authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: StringIO.new(creds_hash.to_json),
        scope: scopes
      )
      return authorizer.fetch_access_token!['access_token']
    end

    # Стандартний метод (для локальної розробки, де є файл)
    authorizer = Google::Auth.get_application_default(scopes)
    authorizer.fetch_access_token!['access_token']
  end

  def payload
    # Формат запиту специфічний для VTON API
    {
      instances: [
        {
          personImage: {
            image: { bytesBase64Encoded: download_as_base64(@human_url) }
          },
          productImages: [
            {
              image: { bytesBase64Encoded: download_as_base64(@shoe_url) }
            }
          ]
        }
      ],
      parameters: {
        addWatermark: false,
        sampleCount: 1,
        seed: 42, # Для стабільності результату
        safetySetting: "block_only_high"
        # Примітка: Цей API сам визначає категорію (взуття/одяг)
      }
    }
  end

  def handle_success(response)
    json = JSON.parse(response.body)

    # Отримуємо Base64 рядок з відповіді
    prediction = json["predictions"]&.first

    unless prediction
      puts "⚠️ API returned success but no predictions found."
      return nil
    end

    image_data_base64 = prediction["bytesBase64Encoded"] || prediction["image"]&.fetch("bytesBase64Encoded")

    if image_data_base64
      # 1. Декодуємо Base64 у бінарні дані
      binary_data = Base64.decode64(image_data_base64)

      # 2. Створюємо віртуальний файл у пам'яті
      io = StringIO.new(binary_data)

      puts "✅ Success! Image processed in memory."

      # 3. Повертаємо об'єкт IO (StringIO)
      return io
    else
      puts "⚠️ Unknown response format: #{json}"
      return nil
    end
  end

  def handle_error(response)
    puts "❌ API Error (#{response.status}):"
    puts response.body
  end

  # --- Допоміжні методи ---

  def download_as_base64(url)
    puts "📥 Downloading: #{url}..."
    # Простий завантажувач без зайвих перевірок
    data = URI.open(url).read
    Base64.strict_encode64(data)
  end
end

# --- ЗАПУСК ---

# TryShoes.new(
#   human_url: "https://sport-discount.com.ua/image/cache/data/nike/898050-400-2-585x585.jpg",
#   # ТЕПЕР ВИКОРИСТОВУЄМО ФОТО ТОВАРУ!
#   shoe_url:  "https://megasport.ua/api/s3/images/megasport-dev/products/3555570144/68c96605d4c8e-72715d0.png"
# ).call