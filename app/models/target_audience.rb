class TargetAudience < ApplicationRecord
  has_many :users
  has_many :shoes

  has_and_belongs_to_many :searches

  def man? = name == 'man'
  def woman? = name == 'woman'
end

# == Schema Information
#
# Table name: target_audiences
#
#  id   :bigint           not null, primary key
#  name :string           not null
#
