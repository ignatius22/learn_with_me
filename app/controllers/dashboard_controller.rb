class DashboardController < ApplicationController
  before_action :student_profile_required
  
  def index
    @current_enrollments = current_student.enrollments.includes(:course)
                                          .where(status: ['enrolled', 'completed'])
                                          .order(:created_at)
                                          .limit(5)
    
    # Find the most recently accessed course that's not completed for "Continue Learning"
    @continue_learning = current_student.enrollments.includes(:course)
                                       .where(status: 'enrolled')
                                       .where('enrollments.progress_percentage < 100 OR enrollments.progress_percentage IS NULL')
                                       .order(:updated_at)
                                       .first
    
    @recommended_courses = Course.includes(:author)
                                .where.not(id: current_student.courses.ids)
                                .order(:created_at)
                                .limit(6)
    
    @recent_activity = current_student.enrollments
                                     .includes(:course)
                                     .order(:updated_at)
                                     .limit(5)
    
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
end

