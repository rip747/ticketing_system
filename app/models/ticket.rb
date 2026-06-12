class Ticket < ApplicationRecord
  belongs_to :user
  belongs_to :assigned_user, class_name: "User", optional: true
  belongs_to :category
  belongs_to :department
  has_many :comments, dependent: :destroy
  has_rich_text :description

  validates :subject, presence: true
  validates :description, presence: true
  validates :status, presence: true, inclusion: { in: %w[open pending resolved closed] }
  validates :priority, presence: true, inclusion: { in: %w[low medium high urgent] }

  scope :open, -> { where(status: "open") }
  scope :pending, -> { where(status: "pending") }
  scope :resolved, -> { where(status: "resolved") }
  scope :closed, -> { where(status: "closed") }
  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :by_priority, ->(priority) { where(priority: priority) if priority.present? }
  scope :by_department, ->(department_id) { where(department_id: department_id) if department_id.present? }
  scope :recent, -> { order(updated_at: :desc) }
  scope :unassigned, -> { where(assigned_user_id: nil) }

  def open?
    status == "open"
  end

  def pending?
    status == "pending"
  end

  def resolved?
    status == "resolved"
  end

  def closed?
    status == "closed"
  end

  def close!
    update(status: "closed", closed_at: Time.current)
  end

  def assign_to!(user)
    update(assigned_user: user, status: "pending") if open?
  end
end
