class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  # Enable CSRF protection
  protect_from_forgery with: :exception
  
  # Current student helper
  def current_student
    @current_student ||= current_user&.student
  end
  helper_method :current_student
  
  # Admin check
  def admin_required
    redirect_to root_path unless current_user&.admin?
  end
  
  # Student profile required
  def student_profile_required
    redirect_to new_profile_path unless current_student
  end
  
  # Health check endpoint
  def health
    render json: { status: 'ok', timestamp: Time.current }
  end
  
private
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:student_attributes => [:first_name, :last_name]])
    devise_parameter_sanitizer.permit(:account_update, keys: [:student_attributes => [:first_name, :last_name]])
  end
end
