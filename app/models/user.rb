class User < ApplicationRecord
  belongs_to :department, optional: true
  has_many :tickets, dependent: :restrict_with_error
  has_many :assigned_tickets, class_name: "Ticket", foreign_key: :assigned_user_id, dependent: :nullify
  has_many :comments, dependent: :destroy

  has_secure_password

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: %w[customer agent admin] }

  scope :agents, -> { where(role: "agent") }
  scope :admins, -> { where(role: "admin") }
  scope :customers, -> { where(role: "customer") }

  def agent_or_admin?
    role.in?(%w[agent admin])
  end

  def admin?
    role == "admin"
  end

  def customer?
    role == "customer"
  end
end
