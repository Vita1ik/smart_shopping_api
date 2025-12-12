class Category < ApplicationRecord
  has_and_belongs_to_many :searches
  has_and_belongs_to_many :sources
  has_many :shoes
end

# == Schema Information
#
# Table name: categories
#
#  id   :bigint           not null, primary key
#  name :string           not null
#  slug :string           not null
#
# Indexes
#
#  index_categories_on_slug  (slug) UNIQUE
#
