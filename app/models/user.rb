class User < ApplicationRecord
  ROLES = %w[customer agent org_admin sys_admin].freeze

  belongs_to :organization, optional: true
  belongs_to :department, optional: true
  has_many :tickets, dependent: :restrict_with_error
  has_many :assigned_tickets, class_name: "Ticket", foreign_key: :assigned_user_id, dependent: :nullify
  has_many :comments, dependent: :destroy

  has_secure_password

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: ROLES }

  scope :agents, -> { where(role: "agent") }
  scope :org_admins, -> { where(role: "org_admin") }
  scope :sys_admins, -> { where(role: "sys_admin") }
  scope :customers, -> { where(role: "customer") }
  scope :by_organization, ->(org) { where(organization_id: org.id) }

  def agent_or_admin?
    role.in?(%w[agent org_admin])
  end

  def org_admin?
    role == "org_admin"
  end

  def sys_admin?
    role == "sys_admin"
  end

  def customer?
    role == "customer"
  end

  def can_manage_organization?
    org_admin? || sys_admin?
  end
end
