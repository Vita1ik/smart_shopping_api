class Source < ApplicationRecord
  has_many :shoes
  has_and_belongs_to_many :categories
end
