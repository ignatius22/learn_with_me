class Review < ApplicationRecord
  belongs_to :student
  belongs_to :course

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :student_id, uniqueness: { scope: :course_id, message: "can only review a course once" }
end

