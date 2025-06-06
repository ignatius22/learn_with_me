class Section < ApplicationRecord
  belongs_to :course
  has_many :lessons, dependent: :destroy

  validates :title, presence: true
  validates :position, presence: true, uniqueness: { scope: :course_id }

  scope :ordered, -> { order(:position) }
end

