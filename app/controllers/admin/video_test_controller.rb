class Admin::VideoTestController < Admin::BaseController
  def index
    authorize :admin, :manage_lessons?
    @quick_lesson = Lesson.new
    @recent_videos = Lesson.where(content_type: 'video')
                           .includes(:video_file_attachment, :video_thumbnail_attachment, :section => :course)
                           .limit(20)
                           .order(created_at: :desc)
    @courses_with_sections = Course.includes(:sections).where.not(sections: { id: nil })
  end

  def quick_upload
    authorize :admin, :manage_lessons?
    
    @quick_lesson = Lesson.new(quick_lesson_params)
    @quick_lesson.content_type = 'video'
    
    # Find the selected course and section
    section = Section.find(params[:lesson][:section_id])
    @quick_lesson.section = section
    @quick_lesson.position = (section.lessons.maximum(:position) || 0) + 1
    
    if @quick_lesson.save
      render json: {
        status: 'success',
        message: 'Video lesson created successfully!',
        lesson_id: @quick_lesson.id,
        lesson_title: @quick_lesson.title,
        course_title: section.course.title,
        section_title: section.title,
        video_url: @quick_lesson.video_url,
        thumbnail_url: @quick_lesson.thumbnail_url,
        file_size: @quick_lesson.video_file.attached? ? @quick_lesson.video_file.blob.byte_size : 0,
        duration: @quick_lesson.video_duration,
        edit_url: edit_admin_course_section_lesson_path(section.course, section, @quick_lesson)
      }
    else
      render json: {
        status: 'error',
        errors: @quick_lesson.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def processing_status
    authorize :admin, :manage_lessons?
    lesson = Lesson.find(params[:lesson_id])
    
    render json: {
      video_duration: lesson.video_duration,
      video_file_size: lesson.video_file_size,
      video_filename: lesson.video_filename,
      thumbnail_attached: lesson.video_thumbnail.attached?,
      thumbnail_url: lesson.thumbnail_url
    }
  end

  private

  def quick_lesson_params
    params.require(:lesson).permit(:title, :video_file, :video_thumbnail, :section_id)
  end
end

