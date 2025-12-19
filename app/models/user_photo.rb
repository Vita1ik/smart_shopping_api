class UserPhoto < ApplicationRecord
  belongs_to :user
  belongs_to :shoe, optional: true
  has_one_attached :image
  belongs_to :source_photo, class_name: 'UserPhoto', optional: true
  has_many :generated_photos, class_name: 'UserPhoto', foreign_key: 'source_photo_id', dependent: :destroy

  validates :image, presence: true

  scope :generated, -> { where.not(shoe_id: nil) }
  scope :originals, -> { where(shoe_id: nil) }
end

# == Schema Information
#
# Table name: user_photos
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  shoe_id         :bigint
#  source_photo_id :bigint
#  user_id         :bigint           not null
#
# Indexes
#
#  index_user_photos_on_shoe_id          (shoe_id)
#  index_user_photos_on_source_photo_id  (source_photo_id)
#  index_user_photos_on_user_id          (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (shoe_id => shoes.id)
#  fk_rails_...  (source_photo_id => user_photos.id)
#  fk_rails_...  (user_id => users.id)
#
