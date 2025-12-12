class Color < ApplicationRecord
  has_many :shoes
  has_and_belongs_to_many :searches

  before_validation :generate_slug

  def generate_slug
    return unless name.present?

    self.slug ||= name.parameterize
  end
end

# == Schema Information
#
# Table name: colors
#
#  id   :bigint           not null, primary key
#  name :string           not null
#  slug :string           not null
#
# Indexes
#
#  index_colors_on_slug  (slug) UNIQUE
#
