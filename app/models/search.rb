class Search < ApplicationRecord
  belongs_to :user

  has_and_belongs_to_many :brands
  has_and_belongs_to_many :sizes
  has_and_belongs_to_many :colors
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :target_audiences
end

# == Schema Information
#
# Table name: searches
#
#  id          :bigint           not null, primary key
#  price_range :jsonb
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_searches_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
