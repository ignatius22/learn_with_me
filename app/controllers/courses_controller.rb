class CoursesController < ApplicationController
  before_action :set_course, only: [:show, :enroll, :unenroll]
  before_action :authenticate_user!, except: [:browse]
  before_action :ensure_student_profile, only: [:enroll, :unenroll]
  
  def index
    @courses = Course.includes(:author, :enrollments)
    
    # Filter by search query
    if params[:search].present?
      @courses = @courses.where(
        "title ILIKE ? OR description ILIKE ?", 
        "%#{params[:search]}%", 
        "%#{params[:search]}%"
      )
    end
    
    # Filter by price range
    if params[:price_min].present?
      @courses = @courses.where("price >= ?", params[:price_min])
    end
    
    if params[:price_max].present?
      @courses = @courses.where("price <= ?", params[:price_max])
    end
    
    # Order courses by created_at desc and limit for basic pagination
    @courses = @courses.order(created_at: :desc).limit(50)
    
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
  
  def browse
    @featured_courses = Course.includes(:author)
                             .order(:created_at)
                             .limit(6)
    
    @categories = Course.joins(:author)
                       .group('authors.first_name', 'authors.last_name')
                       .count
    
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
  
  def show
    @enrollment = current_student&.enrollments&.find_by(course: @course)
    @reviews = @course.reviews.includes(student: :user).order(:created_at)
    @user_review = current_student ? @reviews.find_by(student: current_student) : nil
    @sections = @course.sections.includes(:lessons).order(:position)
    @total_duration = @course.total_duration
    @lesson_count = @course.total_lessons
    
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
  
  def enroll
    @enrollment = current_student.enrollments.build(
      course: @course,
      status: 'enrolled',
      enrollment_date: Time.current
    )
    
    respond_to do |format|
      if @enrollment.save
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("course_#{@course.id}_enrollment", 
              partial: "courses/enrollment_status", 
              locals: { course: @course, enrollment: @enrollment }
            ),
            turbo_stream.append("flash_messages", 
              partial: "shared/flash_message", 
              locals: { type: "success", message: "Successfully enrolled in #{@course.title}! Ready to start learning?" }
            )
          ]
        end
        format.html { redirect_to study_course_path(@enrollment), notice: "Successfully enrolled! Let's start learning!" }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.append("flash_messages", 
            partial: "shared/flash_message", 
            locals: { type: "error", message: @enrollment.errors.full_messages.join(", ") }
          )
        end
        format.html { redirect_to @course, alert: @enrollment.errors.full_messages.join(", ") }
      end
    end
  end
  
  def unenroll
    @enrollment = current_student.enrollments.find_by(course: @course)
    
    respond_to do |format|
      if @enrollment&.destroy
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("course_#{@course.id}_enrollment", 
              partial: "courses/enrollment_status", 
              locals: { course: @course, enrollment: nil }
            ),
            turbo_stream.append("flash_messages", 
              partial: "shared/flash_message", 
              locals: { type: "info", message: "Unenrolled from #{@course.title}" }
            )
          ]
        end
        format.html { redirect_to @course, notice: "Unenrolled successfully!" }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.append("flash_messages", 
            partial: "shared/flash_message", 
            locals: { type: "error", message: "Failed to unenroll" }
          )
        end
        format.html { redirect_to @course, alert: "Failed to unenroll" }
      end
    end
  end
  
  private
  
  def set_course
    @course = Course.find(params[:id])
  end
  
  def ensure_student_profile
    unless current_student
      redirect_to new_user_registration_path, alert: "Please create a student profile to enroll in courses."
    end
  end
end

