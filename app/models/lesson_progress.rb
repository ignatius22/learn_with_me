class LessonProgress < ApplicationRecord
  belongs_to :student
  belongs_to :lesson
  belongs_to :enrollment

  validates :student_id, uniqueness: { scope: :lesson_id }
  validates :status, inclusion: { in: %w[not_started in_progress completed] }
  validates :progress_percentage, numericality: { in: 0..100 }

  scope :completed, -> { where(status: 'completed') }
  scope :in_progress, -> { where(status: 'in_progress') }

  def mark_as_completed!
    update!(status: 'completed', progress_percentage: 100, completed_at: Time.current)
  end

  def mark_as_started!
    update!(status: 'in_progress', started_at: Time.current) if status == 'not_started'
  end
end

