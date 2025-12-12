class Source < ApplicationRecord
  has_many :shoes
  has_and_belongs_to_many :categories
end

# == Schema Information
#
# Table name: sources
#
#  id               :bigint           not null, primary key
#  integration_type :string           not null
#  name             :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
