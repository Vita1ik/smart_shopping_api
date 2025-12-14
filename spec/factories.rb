FactoryBot.define do
  # --- Lookup Tables ---

  factory :brand do
    name { FFaker::Product.brand }
  end

  factory :category do
    name { FFaker::Product.product_name }
  end

  factory :color do
    name { FFaker::Color.name }
  end

  factory :size do
    name { rand(36..48).to_s }
  end

  factory :target_audience do
    name { %w[Men Women Kids Unisex].sample }
  end

  factory :source do
    name { FFaker::Company.name }
    integration_type { %w[shopify magento woocommerce custom].sample }
  end

  # --- Admin Users ---

  factory :admin_user do
    email { FFaker::Internet.unique.email }
    password { 'password' }
  end

  # --- App Users ---

  factory :user do
    email { FFaker::Internet.unique.email }
    password { 'password123' }
    first_name { FFaker::Name.first_name }
    last_name { FFaker::Name.last_name }
    avatar { FFaker::Avatar.image }

    # Associations
    size
    target_audience

    trait :with_google do
      google_uid { FFaker::Guid.guid }
    end
  end

  # --- Main Product (Shoe) ---

  factory :shoe do
    name { FFaker::Product.product_name }
    images { [FFaker::Image.url, FFaker::Image.url] }
    price { rand(1000..50000) } # Price in cents
    product_url { FFaker::Internet.http_url }
    prev_prices { { "2024-01-01": 5000 } }

    # Required Associations
    brand
    category
    size
    color
    target_audience
    source
  end

  # --- Join Tables & Interactions ---

  # NOTE: explicit class required because table is 'users_shoes'
  factory :user_shoe, class: 'UserShoe' do
    user
    shoe
    liked { [true, false].sample }
  end

  factory :search do
    user
    price_range { { min: rand(100..500), max: rand(600..1000) } }

    # Example of adding related collections in HABTM
    trait :with_filters do
      after(:create) do |search|
        search.brands << create(:brand)
        search.categories << create(:category)
      end
    end
  end
end