class Organization < ApplicationRecord
  has_many :users, dependent: :restrict_with_error
  has_many :departments, dependent: :restrict_with_error
  has_many :categories, dependent: :restrict_with_error
  has_many :tickets, dependent: :restrict_with_error
  has_many :comments, dependent: :restrict_with_error

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug, on: :create

  private

  def generate_slug
    return if slug.present?
    base = name.parameterize(preserve_case: false)
    self.slug = base
    # Ensure uniqueness
    counter = 1
    while Organization.exists?(slug: slug)
      self.slug = "#{base}-#{counter}"
      counter += 1
    end
  end
end
