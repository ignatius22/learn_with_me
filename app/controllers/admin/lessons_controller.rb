class Admin::LessonsController < Admin::BaseController
  before_action :set_course_and_section
  before_action :set_lesson, only: [:show, :edit, :update, :destroy]

  def index
    authorize Lesson, :manage?
    @lessons = @section.lessons.ordered.includes(:video_file_attachment, :video_thumbnail_attachment)
  end

  def show
    authorize @lesson, :show?
  end

  def new
    @lesson = @section.lessons.build
    authorize @lesson, :new?
    @lesson.position = (@section.lessons.maximum(:position) || 0) + 1
  end

  def create
    @lesson = @section.lessons.build(lesson_params)
    authorize @lesson, :create?
    @lesson.position = (@section.lessons.maximum(:position) || 0) + 1 if @lesson.position.blank?
    
    if @lesson.save
      redirect_to admin_course_section_lesson_path(@course, @section, @lesson), 
                  notice: 'Lesson was successfully created.'
    else
      render :new
    end
  end

  def edit
    authorize @lesson, :edit?
  end

  def update
    authorize @lesson, :update?
    if @lesson.update(lesson_params)
      redirect_to admin_course_section_lesson_path(@course, @section, @lesson), 
                  notice: 'Lesson was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    authorize @lesson, :destroy?
    @lesson.destroy
    redirect_to admin_course_section_lessons_path(@course, @section), 
                notice: 'Lesson was successfully deleted.'
  end

  # AJAX endpoint for video upload progress
  def upload_progress
    authorize Lesson, :upload_progress?
    render json: { status: 'uploading' }
  end

  private

  def set_course_and_section
    @course = Course.find(params[:course_id])
    @section = @course.sections.find(params[:section_id])
  end

  def set_lesson
    @lesson = @section.lessons.find(params[:id])
  end

  def lesson_params
    params.require(:lesson).permit(
      :title, :content_type, :content_url, :text_content, :duration_in_minutes, :position,
      :video_file_url, :video_thumbnail_url, :video_file, :video_thumbnail
    )
  end

  def authenticate_admin!
    redirect_to root_path unless current_user&.admin?
  end
end

