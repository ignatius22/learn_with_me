class ProcessVideoMetadataJob < ApplicationJob
  queue_as :default

  def perform(lesson)
    return unless lesson.video_file.attached?

    begin
      # Get video metadata using ffprobe if available
      video_path = ActiveStorage::Blob.service.path_for(lesson.video_file.key)
      
      if command_exists?('ffprobe')
        # Get video duration
        duration_cmd = "ffprobe -v quiet -show_entries format=duration -of csv=p=0 '#{video_path}'"
        duration_output = `#{duration_cmd}`.strip
        duration_seconds = duration_output.to_f.round if duration_output.present?
        
        # Get video dimensions for thumbnail generation
        dimensions_cmd = "ffprobe -v quiet -select_streams v:0 -show_entries stream=width,height -of csv=p=0 '#{video_path}'"
        dimensions_output = `#{dimensions_cmd}`.strip
        
        # Generate thumbnail at 10% of video duration
        if duration_seconds && duration_seconds > 0
          thumbnail_time = [duration_seconds * 0.1, 10].min # At least 10 seconds in, or 10% of duration
          
          thumbnail_path = Rails.root.join('tmp', "thumbnail_#{lesson.id}_#{Time.current.to_i}.jpg")
          thumbnail_cmd = "ffmpeg -i '#{video_path}' -ss #{thumbnail_time} -frames:v 1 -q:v 2 '#{thumbnail_path}' -y"
          
          if system(thumbnail_cmd)
            # Attach thumbnail to lesson
            lesson.video_thumbnail.attach(
              io: File.open(thumbnail_path),
              filename: "thumbnail_#{lesson.id}.jpg",
              content_type: 'image/jpeg'
            )
            
            # Clean up temp file
            File.delete(thumbnail_path) if File.exist?(thumbnail_path)
          end
        end
        
        # Update lesson with metadata
        lesson.update_columns(
          video_duration: duration_seconds&.round,
          video_file_size: lesson.video_file.blob.byte_size,
          video_filename: lesson.video_file.blob.filename.to_s,
          video_content_type: lesson.video_file.blob.content_type,
          duration_in_minutes: duration_seconds ? (duration_seconds / 60).round : nil
        )
      else
        # Fallback: just update basic file information
        lesson.update_columns(
          video_file_size: lesson.video_file.blob.byte_size,
          video_filename: lesson.video_file.blob.filename.to_s,
          video_content_type: lesson.video_file.blob.content_type
        )
        
        Rails.logger.warn "ffprobe not available. Video metadata processing limited."
      end
      
    rescue StandardError => e
      Rails.logger.error "Error processing video metadata for lesson #{lesson.id}: #{e.message}"
      Sentry.capture_exception(e) if defined?(Sentry)
    end
  end

  private

  def command_exists?(command)
    system("which #{command} > /dev/null 2>&1")
  end
end
