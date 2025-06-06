class ProfilesController < ApplicationController
  before_action :set_student, only: [:show, :edit, :update]
  
  def show
    @enrollments_count = @student.enrollments.count
    @completed_courses = @student.enrollments.where(status: 'completed').count
    @recent_enrollments = @student.enrollments.includes(:course).order(:updated_at).limit(5)
    
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
  
  def edit
    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("profile_form", 
          partial: "profiles/form", 
          locals: { student: @student }
        )
      end
    end
  end
  
  def update
    respond_to do |format|
      if @student.update(student_params)
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("profile_details", 
              partial: "profiles/details", 
              locals: { student: @student }
            ),
            turbo_stream.append("flash_messages", 
              partial: "shared/flash_message", 
              locals: { type: "success", message: "Profile updated successfully!" }
            )
          ]
        end
        format.html { redirect_to profile_path, notice: "Profile updated successfully!" }
      else
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("profile_form", 
              partial: "profiles/form", 
              locals: { student: @student }
            ),
            turbo_stream.append("flash_messages", 
              partial: "shared/flash_message", 
              locals: { type: "error", message: @student.errors.full_messages.join(", ") }
            )
          ]
        end
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end
  
  private
  
  def set_student
    @student = current_student || current_user.build_student
  end
  
  def student_params
    params.require(:student).permit(:first_name, :last_name)
  end
end

