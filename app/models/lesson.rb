class Lesson < ApplicationRecord
  belongs_to :section
  has_many :lesson_progresses, dependent: :destroy
  has_many :students_with_progress, through: :lesson_progresses, source: :student

  # Active Storage attachments for video content
  has_one_attached :video_file
  has_one_attached :video_thumbnail
  
  validates :title, presence: true
  validates :content_type, presence: true, inclusion: { in: %w[video text audio quiz] }
  validates :position, presence: true, uniqueness: { scope: :section_id }

  scope :ordered, -> { order(:position) }
  scope :videos, -> { where(content_type: 'video') }

  # Validate that at least one content field is present
  validate :content_present
  validate :video_file_valid, if: -> { content_type == 'video' && video_file.attached? }

  # Callbacks for video processing
  after_commit :process_video_metadata, if: -> { video_file.attached? && saved_change_to_id? }

  def video_url
    return video_file_url if video_file_url.present?
    return Rails.application.routes.url_helpers.rails_blob_path(video_file, only_path: true) if video_file.attached?
    content_url if content_type == 'video'
  end

  def thumbnail_url
    return video_thumbnail_url if video_thumbnail_url.present?
    return Rails.application.routes.url_helpers.rails_blob_path(video_thumbnail, only_path: true) if video_thumbnail.attached?
    nil
  end

  def formatted_duration
    return "0:00" unless duration_in_minutes&.positive?
    
    hours = duration_in_minutes / 60
    minutes = duration_in_minutes % 60
    
    if hours > 0
      "#{hours}:#{minutes.to_s.rjust(2, '0')}"
    else
      "#{minutes}:00"
    end
  end

  def video_duration_display
    return formatted_duration if video_duration.present?
    
    if video_duration && video_duration > 0
      total_seconds = video_duration
      hours = total_seconds / 3600
      minutes = (total_seconds % 3600) / 60
      seconds = total_seconds % 60
      
      if hours > 0
        "%d:%02d:%02d" % [hours, minutes, seconds]
      else
        "%d:%02d" % [minutes, seconds]
      end
    else
      "0:00"
    end
  end

  private

  def content_present
    case content_type
    when 'video'
      if content_url.blank? && video_file_url.blank? && !video_file.attached?
        errors.add(:base, "Video lessons must have either a video file upload, video URL, or content URL")
      end
    when 'text'
      if text_content.blank?
        errors.add(:base, "Text lessons must have text content")
      end
    else
      if content_url.blank? && text_content.blank? && !video_file.attached?
        errors.add(:base, "Must have content")
      end
    end
  end

  def video_file_valid
    return unless video_file.attached?
    
    # Check file size (max 500MB)
    if video_file.blob.byte_size > 500.megabytes
      errors.add(:video_file, "must be less than 500MB")
    end
    
    # Check content type
    allowed_types = ['video/mp4', 'video/webm', 'video/ogg', 'video/avi', 'video/mov', 'video/wmv']
    unless allowed_types.include?(video_file.blob.content_type)
      errors.add(:video_file, "must be a valid video format (MP4, WebM, OGG, AVI, MOV, WMV)")
    end
  end

  def process_video_metadata
    ProcessVideoMetadataJob.perform_later(self) if video_file.attached?
  end
end

