class UserShoe < ApplicationRecord
  self.table_name = "users_shoes"

  belongs_to :user
  belongs_to :shoe

  validates :user_id, uniqueness: { scope: :shoe_id }

  def discount!(new_price)
    update!(discounted: true, current_price: new_price, prev_price: current_price)
  end

  def like!
    update!(liked: true, current_price: shoe.price)
  end

  def dislike!
    update!(liked: false)
  end
end

# == Schema Information
#
# Table name: users_shoes
#
#  id                            :bigint           not null, primary key
#  current_price                 :integer
#  discounted                    :boolean
#  liked                         :boolean          default(FALSE), not null
#  prev_price                    :integer
#  visited_discounted_from_email :boolean
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  shoe_id                       :bigint           not null
#  user_id                       :bigint           not null
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
