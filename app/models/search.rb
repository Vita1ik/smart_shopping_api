class Search < ApplicationRecord
  belongs_to :user

  has_and_belongs_to_many :brands
  has_and_belongs_to_many :sizes
  has_and_belongs_to_many :colors
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :target_audiences
end
