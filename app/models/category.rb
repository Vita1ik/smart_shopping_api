class Category < ApplicationRecord
  has_and_belongs_to_many :searches
  has_and_belongs_to_many :sources
  has_many :shoes
end
