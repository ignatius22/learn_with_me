class Role < ApplicationRecord
  # A Role can have many students.
  # 'dependent: :restrict_with_error' ensures that a role cannot be deleted
  # if there are students associated with it, matching the ON DELETE NO ACTION
  # foreign key constraint in your main.sql Canvas.
  has_many :students, dependent: :restrict_with_error

  # Validations to ensure data integrity at the application level.
  # 'presence: true' ensures the name is not blank.
  validates :name, presence: true
  # 'inclusion' validates that the name is one of the predefined ENUM values.
  # This provides application-level validation before hitting the database.
  # The values here must match the ENUM values defined in your main.sql:
  # CREATE TYPE role_type AS ENUM ('student', 'author', 'admin');
  validates :name, inclusion: { in: %w[student author admin],
                                message: "%{value} is not a valid role type" }
  # The 'uniqueness: true' validation is removed here because the
  # ENUM type combined with UNIQUE constraint in PostgreSQL
  # already enforces uniqueness at the database level.
end
