class AddProgressPercentageToEnrollments < ActiveRecord::Migration[8.0]
  def change
    add_column :enrollments, :progress_percentage, :decimal, precision: 5, scale: 2, default: 0.0
  end
end
