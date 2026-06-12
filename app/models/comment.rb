class Comment < ApplicationRecord
  belongs_to :organization
  belongs_to :user
  belongs_to :ticket

  validates :body, presence: true

  scope :recent, -> { order(created_at: :asc) }
  scope :for_organization, ->(org) { where(organization_id: org.id) }
end
