class CreateLessonProgresses < ActiveRecord::Migration[7.1]
  def change
    create_table :lesson_progresses do |t|
      t.references :student, null: false, foreign_key: true
      t.references :lesson, null: false, foreign_key: true
      t.references :enrollment, null: false, foreign_key: true
      t.string :status, default: 'not_started', null: false
      t.decimal :progress_percentage, precision: 5, scale: 2, default: 0.0, null: false
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :lesson_progresses, [:student_id, :lesson_id], unique: true
    add_index :lesson_progresses, :status
  end
end
