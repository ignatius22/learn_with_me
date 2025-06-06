class Course < ApplicationRecord
  # A Course belongs to one Author.
  # This sets up the association based on the 'author_id' foreign key.
  belongs_to :author

  # A Course can have many enrollments.
  # 'dependent: :destroy' ensures that if a course is deleted,
  # all its associated enrollments are also deleted, matching the
  # ON DELETE CASCADE foreign key constraint in your main.sql Canvas.
  has_many :enrollments, dependent: :destroy

  # A Course can have many students through enrollments.
  # This sets up the many-to-many relationship.
  has_many :students, through: :enrollments

  # A Course can have many reviews from students
  has_many :reviews, dependent: :destroy

  # A Course can have many sections, which contain lessons
  has_many :sections, dependent: :destroy
  has_many :lessons, through: :sections

  # Validations for course attributes.
  validates :title, presence: true, uniqueness: true
  # 'numericality' ensures the price is a number and greater than or equal to zero.
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  # Ensures that a course is always associated with an author.
  validates :author, presence: true

  # Helper methods
  def average_rating
    return 0 if reviews.empty?
    reviews.average(:rating).to_f.round(1)
  end

  def total_lessons
    lessons.count
  end

  def total_duration
    lessons.sum(:duration_in_minutes) || 0
  end
end
