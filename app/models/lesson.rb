class Lesson < ApplicationRecord
  belongs_to :section
  has_many :lesson_progresses, dependent: :destroy
  has_many :students_with_progress, through: :lesson_progresses, source: :student

  validates :title, presence: true
  validates :content_type, presence: true, inclusion: { in: %w[video text audio quiz] }
  validates :position, presence: true, uniqueness: { scope: :section_id }

  scope :ordered, -> { order(:position) }

  # Validate that at least one content field is present
  validate :content_present

  private

  def content_present
    if content_url.blank? && text_content.blank?
      errors.add(:base, "Must have either content URL or text content")
    end
  end
end

