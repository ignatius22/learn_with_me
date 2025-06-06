class CreateEnrollments < ActiveRecord::Migration[8.0]
  def change
    create_table :enrollments do |t|
      t.references :student, null: false, foreign_key: { on_delete: :cascade }
      t.references :course, null: false, foreign_key: { on_delete: :cascade }
      t.datetime :enrollment_date, null: false, default: -> { 'NOW()' } # Raw SQL default
      t.string :status, default: 'enrolled'

      t.timestamps

      t.index [:student_id, :course_id], unique: true # Composite unique index
    end
  end
end
