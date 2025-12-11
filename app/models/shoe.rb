class Shoe < ApplicationRecord
  belongs_to :brand
  belongs_to :size
  belongs_to :color
  belongs_to :target_audience
  belongs_to :source
  belongs_to :category

  has_many :user_shoes, dependent: :destroy
  has_many :users, through: :user_shoes
end
