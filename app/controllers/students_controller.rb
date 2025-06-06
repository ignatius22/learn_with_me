# app/controllers/students_controller.rb
class StudentsController < ApplicationController
  # This filter ensures that only authenticated students (or users, if you have another model)
  # can access the actions in this controller.
  # For an admin interface, you might want a different authentication/authorization check,
  # e.g., 'before_action :authenticate_admin!' or 'before_action :authenticate_student!, :authorize_admin!'


  # GET /students
  # Displays a list of all students.
  def index
    @students = Student.all
  end

  # GET /students/:id
  # Displays details for a single student.
  def show
    @student = Student.find(params[:id])
  end

  # GET /students/new
  # Initializes a new student object for the creation form.
  # IMPORTANT: If this is for user self-registration, Devise handles this via
  # new_student_registration_path. This 'new' action is typically for admin
  # creation of student accounts, or if you've explicitly disabled Devise's
  # :registerable module and are handling all registration manually.
  def new
    @student = Student.new
  end

  # POST /students
  # Creates a new student record based on form submission.
  # IMPORTANT: Similar to 'new', if this is for user self-registration,
  # Devise handles this via student_registration_path. This 'create' action
  # is typically for admin creation of student accounts.
  def create
    @student = Student.new(student_params)

    # Assign the role if a role_id parameter is present.
    # This assumes 'role_id' is passed directly in params, not nested under :student.
    # If role_id is nested (e.g., params[:student][:role_id]), it should be permitted
    # in student_params and assigned automatically by Active Record.
    # The current implementation (params[:role_id]) suggests it's a top-level param.
    # If role_id is passed as part of student_params, remove this explicit assignment.
    if params[:role_id].present?
      @student.role = Role.find(params[:role_id])
    end

    # Attempt to save the student record.
    if @student.save
      # Redirect to the student's show page on success.
      redirect_to @student, notice: "Student was successfully created."
    else
      # Re-render the new form with errors if validation fails.
      # Use 'status: :unprocessable_entity' for correct HTTP response.
      render :new, status: :unprocessable_entity
    end
  end

  # GET /students/:id/edit
  # Initializes a student object for the edit form.
  def edit
    @student = Student.find(params[:id])
  end

  # PATCH/PUT /students/:id
  # Updates an existing student record.
  def update
    @student = Student.find(params[:id])
    # Attempt to update the student record.
    if @student.update(student_params)
      # Redirect to the student's show page on success.
      # Use 'status: :see_other' for correct HTTP response after PUT/PATCH.
      redirect_to @student, notice: "Student was successfully updated.", status: :see_other
    else
      # Re-render the edit form with errors if validation fails.
      # Use 'status: :unprocessable_entity' for correct HTTP response.
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /students/:id
  # Deletes a student record.
  def destroy
    @student = Student.find(params[:id])
    @student.destroy
    # Redirect to the students index page on success.
    # Use 'status: :see_other' for correct HTTP response after DELETE.
    redirect_to students_url, notice: "Student was successfully deleted.", status: :see_other
  rescue ActiveRecord::DeleteRestrictionError => e
    # Handle cases where deletion is restricted by foreign key constraints.
    # For example, if a student has enrollments and 'dependent: :restrict_with_error'
    # is used on the association, this will catch it.
    redirect_to students_url, alert: e.message
  end

  private

  # Strong parameters method to permit allowed attributes for student.
  # IMPORTANT: Devise handles 'email', 'password', 'password_confirmation' internally.
  # If this controller is for admin creation, you might need to permit these here.
  # If this is for admin *updates*, you should NOT permit password fields directly
  # unless you're explicitly handling password changes in this controller.
  def student_params
    # Permitting first_name, last_name.
    # If role_id is passed as a nested parameter (e.g., student[role_id]),
    # it needs to be permitted here.
    params.require(:student).permit(:first_name, :last_name, :role_id)
  end
end
