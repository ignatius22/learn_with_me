class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_one :student, dependent: :destroy
  accepts_nested_attributes_for :student
  
  # Helper methods
  def student?
    student.present?
  end
  
  def full_name
    student&.full_name || email.split('@').first.humanize
  end

  def admin?
    student&.role&.name == 'admin'
  end
end
