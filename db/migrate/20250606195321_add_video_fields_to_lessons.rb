class AddVideoFieldsToLessons < ActiveRecord::Migration[8.0]
  def change
    add_column :lessons, :video_file_url, :text
    add_column :lessons, :video_file_size, :integer
    add_column :lessons, :video_duration, :integer
    add_column :lessons, :video_thumbnail_url, :text
    add_column :lessons, :video_filename, :string
    add_column :lessons, :video_content_type, :string
    
    # Add index for video lessons
    add_index :lessons, :content_type
  end
end
