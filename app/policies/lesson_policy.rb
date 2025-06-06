class LessonPolicy < ApplicationPolicy
  def index?
    true # Everyone can view lessons
  end

  def show?
    true # Everyone can view lesson details
  end

  def create?
    user&.admin?
  end

  def new?
    create?
  end

  def update?
    user&.admin?
  end

  def edit?
    update?
  end

  def destroy?
    user&.admin?
  end

  def upload_progress?
    user&.admin?
  end

  def manage?
    user&.admin?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end

