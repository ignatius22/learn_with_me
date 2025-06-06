class CreateCourses < ActiveRecord::Migration[8.0]
  def change
    create_table :courses do |t|
      t.string :title, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, null: false, default: 0.00 # Manually added precision, scale, null, and default
      t.integer :duration_in_hours
      t.references :author, null: false, foreign_key: { on_delete: :restrict } # Added null: false and ON DELETE NO ACTION (restrict)

      t.timestamps
    end
    add_index :courses, :title, unique: true # Explicitly add unique index
  end
end
