class Author < ApplicationRecord
  # An Author can have many courses.
  # 'dependent: :restrict_with_error' ensures an author cannot be deleted
  # if they have courses associated with them, matching the ON DELETE RESTRICT
  # foreign key constraint in your main.sql Canvas.
  has_many :courses, dependent: :restrict_with_error

  # Validations for author attributes.
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
