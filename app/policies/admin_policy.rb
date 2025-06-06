class AdminPolicy < ApplicationPolicy
  def initialize(user, record)
    @user = user
    @record = record
  end

  def access?
    user&.admin?
  end

  def dashboard?
    access?
  end

  def manage_courses?
    access?
  end

  def manage_users?
    access?
  end

  def manage_lessons?
    access?
  end

  def view_analytics?
    access?
  end

  private

  attr_reader :user, :record
end

