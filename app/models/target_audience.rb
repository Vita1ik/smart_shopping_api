class TargetAudience < ApplicationRecord
  has_many :users
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
# Table name: target_audiences
#
#  id   :bigint           not null, primary key
#  name :string           not null
#  slug :string           not null
#
# Indexes
#
#  index_target_audiences_on_slug  (slug) UNIQUE
#
