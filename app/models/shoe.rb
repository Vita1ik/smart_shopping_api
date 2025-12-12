class Shoe < ApplicationRecord
  belongs_to :brand
  belongs_to :size
  belongs_to :color
  belongs_to :target_audience
  belongs_to :source
  belongs_to :category

  has_many :user_shoes, class_name: 'UserShoe', dependent: :destroy
  has_many :users, through: :user_shoes
end

# == Schema Information
#
# Table name: shoes
#
#  id                 :bigint           not null, primary key
#  images             :jsonb            not null
#  name               :string           not null
#  prev_prices        :jsonb
#  price              :bigint           not null
#  product_url        :text             not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  brand_id           :bigint           not null
#  category_id        :bigint           not null
#  color_id           :bigint           not null
#  size_id            :bigint           not null
#  source_id          :bigint           not null
#  target_audience_id :bigint           not null
#
# Indexes
#
#  index_shoes_on_brand_id            (brand_id)
#  index_shoes_on_category_id         (category_id)
#  index_shoes_on_color_id            (color_id)
#  index_shoes_on_size_id             (size_id)
#  index_shoes_on_source_id           (source_id)
#  index_shoes_on_target_audience_id  (target_audience_id)
#
# Foreign Keys
#
#  fk_rails_...  (brand_id => brands.id)
#  fk_rails_...  (category_id => categories.id)
#  fk_rails_...  (color_id => colors.id)
#  fk_rails_...  (size_id => sizes.id)
#  fk_rails_...  (source_id => sources.id)
#  fk_rails_...  (target_audience_id => target_audiences.id)
#
