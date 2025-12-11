class UserShoe < ApplicationRecord
  self.table_name = "users_shoes"

  belongs_to :user
  belongs_to :shoe

  validates :user_id, uniqueness: { scope: :shoe_id }
end
