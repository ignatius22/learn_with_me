class Enrollment < ApplicationRecord
    # An Enrollment belongs to one Student.
    belongs_to :student

    # An Enrollment belongs to one Course.
    belongs_to :course

    # Validations for enrollment attributes.
    # 'uniqueness: { scope: :course_id }' ensures that a student can only enroll
    # in a specific course once, matching the UNIQUE (student_id, course_id)
    # composite constraint in your main.sql Canvas.
    validates :student_id, uniqueness: { scope: :course_id, message: "has already enrolled in this course" }
    validates :enrollment_date, presence: true
    # 'inclusion' validates that the status is one of the specified values.
    validates :status, presence: true, inclusion: { in: %w[enrolled completed dropped], message: "%{value} is not a valid status" }

    # An enrollment can have many lesson progresses
    has_many :lesson_progresses, dependent: :destroy

    # Helper methods for progress tracking
    def calculate_progress_percentage
      total_lessons = course.lessons.count
      return 0 if total_lessons.zero?
      
      completed_lessons = lesson_progresses.completed.count
      calculated_progress = ((completed_lessons.to_f / total_lessons) * 100).round(1)
      
      # Update the database column with the calculated value
      current_db_value = read_attribute(:progress_percentage)
      update_column(:progress_percentage, calculated_progress) if current_db_value != calculated_progress
      
      calculated_progress
    end
    
    # Override progress_percentage to return the database value or calculate if nil
    def progress_percentage
      db_value = read_attribute(:progress_percentage)
      db_value.presence || calculate_progress_percentage
    end

    def completed_lessons_count
      lesson_progresses.completed.count
    end

    def total_lessons_count
      course.lessons.count
    end

    def next_lesson
      # Find the first lesson that hasn't been completed
      course.lessons.joins(:section)
            .order('sections.position ASC, lessons.position ASC')
            .find { |lesson| !lesson_completed?(lesson) }
    end

    def lesson_completed?(lesson)
      lesson_progresses.completed.exists?(lesson: lesson)
    end

    def lesson_progress_for(lesson)
      lesson_progresses.find_by(lesson: lesson) || 
        lesson_progresses.build(lesson: lesson, student: student, status: 'not_started', progress_percentage: 0)
    end
end
