class Shoe < ApplicationRecord
  belongs_to :brand, optional: true
  belongs_to :size, optional: true
  belongs_to :color, optional: true
  belongs_to :target_audience, optional: true
  belongs_to :source, optional: true
  belongs_to :category, optional: true

  has_many :user_shoes, class_name: 'UserShoe', dependent: :destroy
  has_many :users, through: :user_shoes
  has_and_belongs_to_many :searches

  validates :images, :name, :price, :product_url, presence: true

  scope :by_search_id, ->(search_id) { joins(:searches_shoes).where(searches_shoes: { search_id: }) }
  scope :by_source_name, ->(name) { joins(:source).where(sources: { name: }) }

  def self.ransackable_scopes(_auth_object = nil)
    %i[
      by_source_name
    ]
  end
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
#  brand_id           :bigint
#  category_id        :bigint
#  color_id           :bigint
#  size_id            :bigint
#  source_id          :bigint
#  target_audience_id :bigint
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
