class User < ApplicationRecord
  belongs_to :tenant
  has_many :tickets

  has_secure_password

  validates :email, presence: true, uniqueness: { scope: :tenant_id }
  validates :role, inclusion: { in: %w[user admin] }

  def admin?
    role == "admin"
  end
end
