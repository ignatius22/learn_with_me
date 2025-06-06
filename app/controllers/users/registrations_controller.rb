class Users::RegistrationsController < Devise::RegistrationsController
  before_action :build_student, only: [:new]
  
  private
  
  def build_student
    build_resource({}) if resource.nil?
    resource.build_student if resource.student.nil?
  end
  
  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation, student_attributes: [:first_name, :last_name])
  end
  
  def account_update_params
    params.require(:user).permit(:email, :password, :password_confirmation, :current_password, student_attributes: [:first_name, :last_name])
  end
end

