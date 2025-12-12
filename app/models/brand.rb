class Brand < ApplicationRecord
  before_validation :generate_slug

  has_many :shoes
  has_and_belongs_to_many :searches

  def generate_slug
    return unless name.present?

    self.slug ||= name.parameterize
  end
end

# == Schema Information
#
# Table name: brands
#
#  id   :bigint           not null, primary key
#  name :string           not null
#  slug :string           not null
#
# Indexes
#
#  index_brands_on_slug  (slug) UNIQUE
#
