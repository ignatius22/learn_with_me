class CreateReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :reviews do |t|
      t.references :student, null: false, foreign_key: { on_delete: :cascade }
      t.references :course, null: false, foreign_key: { on_delete: :cascade }
      t.integer :rating, null: false
      t.text :comment

      t.timestamps

      t.index [:student_id, :course_id], unique: true # Composite unique index
    end

    # Add CHECK constraint for rating using raw SQL
    execute "ALTER TABLE reviews ADD CONSTRAINT check_rating_range CHECK (rating >= 1 AND rating <= 5);"
  end
end
