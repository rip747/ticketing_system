class Category < ApplicationRecord
  belongs_to :organization
  belongs_to :department
  has_many :tickets, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { scope: :department_id }

  scope :for_organization, ->(org) { where(organization_id: org.id) }
end
