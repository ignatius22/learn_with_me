class CreateSections < ActiveRecord::Migration[8.0]
  def change
    create_table :sections do |t|
      t.references :course, null: false, foreign_key: { on_delete: :cascade }
      t.string :title, null: false
      t.integer :position, null: false

      t.timestamps
    end
  end
end
