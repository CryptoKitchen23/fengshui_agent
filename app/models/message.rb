class Message < ApplicationRecord
  validates :user_id, presence: true
  validates :role, presence: true
  validates :content, presence: true
  validates :msg_type, presence: true
end