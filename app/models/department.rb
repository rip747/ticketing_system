class Department < ApplicationRecord
  belongs_to :organization
  has_many :users, dependent: :restrict_with_error
  has_many :categories, dependent: :destroy
  has_many :tickets, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { scope: :organization_id }

  scope :for_organization, ->(org) { where(organization_id: org.id) }
end
