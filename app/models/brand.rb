class Brand < ApplicationRecord
  has_many :shoes
  has_and_belongs_to_many :searches
end

# == Schema Information
#
# Table name: brands
#
#  id   :bigint           not null, primary key
#  name :string           not null
#
