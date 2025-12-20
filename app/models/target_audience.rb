class TargetAudience < ApplicationRecord
  has_many :users
  has_many :shoes

  has_and_belongs_to_many :searches
end

# == Schema Information
#
# Table name: target_audiences
#
#  id           :bigint           not null, primary key
#  display_name :string
#  name         :string           not null
#
