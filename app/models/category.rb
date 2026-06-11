class Category < ApplicationRecord
  belongs_to :department
  has_many :tickets, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { scope: :department_id }
end
