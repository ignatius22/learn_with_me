class AddDescriptionToLessons < ActiveRecord::Migration[8.0]
  def change
    add_column :lessons, :description, :text
  end
end
