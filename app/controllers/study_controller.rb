class StudyController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_student_profile
  before_action :set_enrollment, only: [:course, :lesson]
  before_action :set_lesson, only: [:lesson]

  def index
    @enrollments = current_user.student.enrollments.includes(:course)
                                .where(status: ['enrolled', 'completed'])
                                .order(created_at: :desc)
  end

  def course
    @course = @enrollment.course
    @sections = @course.sections.includes(:lessons).ordered
    @current_lesson = @enrollment.next_lesson || @course.lessons.joins(:section)
                                                        .order('sections.position ASC, lessons.position ASC')
                                                        .first
  end

  def lesson
    @course = @enrollment.course
    @sections = @course.sections.includes(:lessons).ordered
    @lesson_progress = @enrollment.lesson_progress_for(@lesson)
    
    # Mark lesson as started if not already
    if @lesson_progress.status == 'not_started'
      @lesson_progress.mark_as_started!
      @lesson_progress.save!
    end

    # Get navigation helpers
    @previous_lesson = previous_lesson
    @next_lesson = next_lesson
  end

  def complete_lesson
    @enrollment = current_user.student.enrollments.find(params[:enrollment_id])
    @lesson = Lesson.find(params[:lesson_id])
    @lesson_progress = @enrollment.lesson_progress_for(@lesson)
    
    @lesson_progress.mark_as_completed!
    @lesson_progress.save!

    # Check if course is completed
    if @enrollment.progress_percentage >= 100
      @enrollment.update!(status: 'completed')
    end

    render json: {
      success: true,
      progress_percentage: @enrollment.progress_percentage,
      next_lesson_id: @enrollment.next_lesson&.id
    }
  rescue StandardError => e
    render json: { success: false, error: e.message }, status: 422
  end

  def update_progress
    @enrollment = current_user.student.enrollments.find(params[:enrollment_id])
    @lesson = Lesson.find(params[:lesson_id])
    @lesson_progress = @enrollment.lesson_progress_for(@lesson)
    
    progress = params[:progress].to_f.clamp(0, 100)
    @lesson_progress.update!(progress_percentage: progress)
    
    # Auto-complete if progress reaches 100%
    if progress >= 100 && @lesson_progress.status != 'completed'
      @lesson_progress.mark_as_completed!
    end

    render json: { success: true, progress: progress }
  rescue StandardError => e
    render json: { success: false, error: e.message }, status: 422
  end

  private

  def ensure_student_profile
    unless current_user.student?
      redirect_to profile_path, alert: 'Please complete your student profile first.'
    end
  end

  def set_enrollment
    @enrollment = current_user.student.enrollments.find(params[:enrollment_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to study_index_path, alert: 'Enrollment not found.'
  end

  def set_lesson
    @lesson = @enrollment.course.lessons.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to study_course_path(@enrollment), alert: 'Lesson not found.'
  end

  def previous_lesson
    course_lessons = @enrollment.course.lessons.joins(:section)
                                .order('sections.position ASC, lessons.position ASC')
    current_index = course_lessons.index(@lesson)
    return nil if current_index.nil? || current_index.zero?
    
    course_lessons[current_index - 1]
  end

  def next_lesson
    course_lessons = @enrollment.course.lessons.joins(:section)
                                .order('sections.position ASC, lessons.position ASC')
    current_index = course_lessons.index(@lesson)
    return nil if current_index.nil?
    
    course_lessons[current_index + 1]
  end
end

