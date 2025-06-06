class Admin::AuthorsController < Admin::BaseController
  before_action :set_author, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_admin!

  def index
    @authors = Author.includes(:courses).page(params[:page]).per(20)
    @authors = @authors.where("first_name ILIKE ? OR last_name ILIKE ? OR email ILIKE ?", 
                             "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%") if params[:search].present?
  end

  def show
    @courses = @author.courses.includes(:sections, :lessons).page(params[:page]).per(10)
  end

  def new
    @author = Author.new
  end

  def create
    @author = Author.new(author_params)
    
    if @author.save
      redirect_to admin_author_path(@author), notice: 'Author was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @author.update(author_params)
      redirect_to admin_author_path(@author), notice: 'Author was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    if @author.courses.any?
      redirect_to admin_authors_path, alert: 'Cannot delete author with associated courses.'
    else
      @author.destroy
      redirect_to admin_authors_path, notice: 'Author was successfully deleted.'
    end
  end

  private

  def set_author
    @author = Author.find(params[:id])
  end

  def author_params
    params.require(:author).permit(:first_name, :last_name, :email, :bio)
  end

  def authenticate_admin!
    redirect_to root_path unless current_user&.admin?
  end
end

