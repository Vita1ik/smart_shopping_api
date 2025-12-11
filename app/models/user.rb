class User < ApplicationRecord
  has_secure_password

  belongs_to :size, optional: true
  belongs_to :target_audience, optional: true

  has_many :searches, dependent: :destroy

  has_many :user_shoes, dependent: :destroy
  has_many :shoes, through: :user_shoes

  has_many :liked_shoes, -> { where(users_shoes: { liked: true }) }, through: :user_shoes, source: :shoe

  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
end