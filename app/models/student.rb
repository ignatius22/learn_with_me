# app/models/student.rb
class Student < ApplicationRecord

  # A Student belongs to one User.
  belongs_to :user

  # A Student belongs to one Role.
  # This sets up the association based on the 'role_id' foreign key.
  belongs_to :role

  # A Student can have many enrollments.
  # 'dependent: :destroy' ensures that if a student is deleted,
  # all their associated enrollments are also deleted, matching the
  # ON DELETE CASCADE foreign key constraint in your main.sql Canvas.
  has_many :enrollments, dependent: :destroy

  # A Student can have many courses through enrollments.
  # This sets up the many-to-many relationship.
  has_many :courses, through: :enrollments

  # A Student can have many reviews for courses
  has_many :reviews, dependent: :destroy

  # A Student can have progress on many lessons
  has_many :lesson_progresses, dependent: :destroy
  has_many :lessons_in_progress, through: :lesson_progresses, source: :lesson

  # Callbacks
  before_validation :set_default_role, on: :create

  # Validations for student attributes.
  validates :first_name, presence: true
  validates :last_name, presence: true
  
  # Helper methods
  def full_name
    "#{first_name} #{last_name}".strip
  end

  private

  def set_default_role
    self.role ||= Role.find_or_create_by(name: 'student')
  end
end
