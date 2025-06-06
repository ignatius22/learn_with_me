class Admin::DashboardController < Admin::BaseController
  def index
    authorize :admin, :dashboard?
    
    @stats = {
      total_users: User.count,
      total_courses: Course.count,
      total_lessons: Lesson.count,
      total_enrollments: Enrollment.count,
      recent_users: User.includes(:student).limit(5).order(created_at: :desc),
      recent_enrollments: Enrollment.includes(:student, :course).limit(5).order(created_at: :desc),
      popular_courses: Course.joins(:enrollments)
                            .group('courses.id')
                            .order('COUNT(enrollments.id) DESC')
                            .limit(5)
                            .includes(:author),
      video_upload_stats: video_upload_statistics
    }
  end

  private

  def video_upload_statistics
    {
      total_video_lessons: Lesson.where(content_type: 'video').count,
      lessons_with_uploads: Lesson.joins(:video_file_attachment).count,
      total_video_size: ActiveStorage::Blob.joins(:attachments)
                                          .where(attachments: { name: 'video_file' })
                                          .sum(:byte_size),
      lessons_without_duration: Lesson.where(content_type: 'video', video_duration: nil).count
    }
  end
end

