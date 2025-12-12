class UserShoe < ApplicationRecord
  self.table_name = "users_shoes"

  belongs_to :user
  belongs_to :shoe

  validates :user_id, uniqueness: { scope: :shoe_id }
end

# == Schema Information
#
# Table name: users_shoes
#
#  id         :bigint           not null, primary key
#  liked      :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  shoe_id    :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_users_shoes_on_shoe_id              (shoe_id)
#  index_users_shoes_on_user_id              (user_id)
#  index_users_shoes_on_user_id_and_shoe_id  (user_id,shoe_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (shoe_id => shoes.id)
#  fk_rails_...  (user_id => users.id)
#
