class CreateLessons < ActiveRecord::Migration[8.0]
  def change
    create_table :lessons do |t|
      t.references :section, null: false, foreign_key: { on_delete: :cascade }
      t.string :title, null: false
      t.string :content_type, null: false
      t.text :content_url
      t.text :text_content
      t.integer :duration_in_minutes
      t.integer :position, null: false

      t.timestamps
    end
  end
end
