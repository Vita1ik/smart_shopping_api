class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :validatable

  belongs_to :size, optional: true
  belongs_to :target_audience, optional: true

  has_many :searches, dependent: :destroy

  has_many :user_shoes, dependent: :destroy
  has_many :shoes, through: :user_shoes

  has_many :liked_shoes, -> { where(users_shoes: { liked: true }) }, through: :user_shoes, source: :shoe

  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
  validates :size, presence: true, if: -> { size_id.present? }
  validates :target_audience, presence: true, if: -> { target_audience_id.present? }
end

# == Schema Information
#
# Table name: users
#
#  id                 :bigint           not null, primary key
#  avatar             :string
#  email              :string
#  encrypted_password :string           default(""), not null
#  first_name         :string
#  google_uid         :string
#  last_name          :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  size_id            :bigint
#  target_audience_id :bigint
#
# Indexes
#
#  index_users_on_email               (email) UNIQUE
#  index_users_on_google_uid          (google_uid)
#  index_users_on_size_id             (size_id)
#  index_users_on_target_audience_id  (target_audience_id)
#
# Foreign Keys
#
#  fk_rails_...  (size_id => sizes.id)
#  fk_rails_...  (target_audience_id => target_audiences.id)
#
