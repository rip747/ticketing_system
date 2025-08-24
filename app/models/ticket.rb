class Ticket < ApplicationRecord
  default_scope { where(tenant_id: Current.tenant_id) }
  belongs_to :user
  belongs_to :tenant

  validates :title, presence: true
  validates :priority, inclusion: { in: %w[low medium high] }
  validates :status, inclusion: { in: %w[open in_progress closed] }

  scope :active, -> { where(status: "open") }
end
