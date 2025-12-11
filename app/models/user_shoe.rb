class UserShoe < ApplicationRecord
  belongs_to :user
  belongs_to :shoe

  validates :user_id, uniqueness: { scope: :shoe_id }
end
