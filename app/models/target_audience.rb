class TargetAudience < ApplicationRecord
  has_many :users
  has_many :shoes

  has_and_belongs_to_many :searches
end
