class Tenant < ApplicationRecord
  has_many :users
  has_many :tickets

  validates :name, presence: true, uniqueness: true
  validates :subdomain, presence: true, uniqueness: true
end
