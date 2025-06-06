class EnrollmentsController < ApplicationController
  before_action :set_enrollment, only: [:show, :progress, :update_status]
  before_action :authenticate_user!
  before_action :ensure_student_profile
  
  def index
    @enrollments = current_student.enrollments
                                 .includes(:course => :author)
                                 .order(:created_at)
    
    # Filter by status
    if params[:status].present?
      @enrollments = @enrollments.where(status: params[:status])
    end
    
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
  
  def show
    @course = @enrollment.course
    @sections = @course.sections.includes(:lessons).order(:position)
    @progress_percentage = calculate_progress_percentage
    
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
  
  def progress
    @progress_data = {
      total_lessons: @enrollment.course.lessons.count,
      completed_lessons: 0, # We'll implement lesson progress later
      percentage: calculate_progress_percentage,
      time_spent: @enrollment.updated_at - @enrollment.created_at
    }
    
    respond_to do |format|
      format.json { render json: @progress_data }
      format.turbo_stream
    end
  end
  
  def update_status
    old_status = @enrollment.status
    
    respond_to do |format|
      if @enrollment.update(status: params[:status])
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("enrollment_#{@enrollment.id}_status", 
              partial: "enrollments/status_badge", 
              locals: { enrollment: @enrollment }
            ),
            turbo_stream.append("flash_messages", 
              partial: "shared/flash_message", 
              locals: { 
                type: "success", 
                message: "Status updated from #{old_status} to #{@enrollment.status}" 
              }
            )
          ]
        end
        format.html { redirect_to @enrollment, notice: "Status updated successfully!" }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.append("flash_messages", 
            partial: "shared/flash_message", 
            locals: { type: "error", message: @enrollment.errors.full_messages.join(", ") }
          )
        end
        format.html { redirect_to @enrollment, alert: @enrollment.errors.full_messages.join(", ") }
      end
    end
  end
  
  private
  
  def set_enrollment
    @enrollment = current_student.enrollments.find(params[:id])
  end
  
  def calculate_progress_percentage
    # Basic calculation - can be enhanced with actual lesson completion tracking
    case @enrollment.status
    when 'enrolled'
      25
    when 'completed'
      100
    when 'dropped'
      0
    else
      0
    end
  end
  
  def ensure_student_profile
    unless current_student
      redirect_to new_user_registration_path, alert: "Please create a student profile to view enrollments."
    end
  end
end

