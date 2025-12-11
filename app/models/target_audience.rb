class TargetAudience < ApplicationRecord
  has_many :users
  has_many :shoes

  has_many :searches_target_audiences
  has_many :searches, through: :searches_target_audiences
end
