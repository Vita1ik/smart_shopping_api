class Size < ApplicationRecord
  has_many :users
  has_many :shoes
  has_and_belongs_to_many :searches
end

# == Schema Information
#
# Table name: sizes
#
#  id   :bigint           not null, primary key
#  name :string           not null
#  slug :string           not null
#
# Indexes
#
#  index_sizes_on_slug  (slug) UNIQUE
#
