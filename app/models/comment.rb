class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :ticket

  validates :body, presence: true

  scope :recent, -> { order(created_at: :asc) }
end
