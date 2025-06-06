class CreateRoles < ActiveRecord::Migration[8.0]
  def change
    # Create the ENUM type first using raw SQL
    # This SQL must match the definition in your main.sql
    execute <<-SQL
      CREATE TYPE role_type AS ENUM ('student', 'author', 'admin');
    SQL

    # Create the roles table, using the custom ENUM type
    create_table :roles do |t|
      # Use the custom ENUM type. Rails typically doesn't directly support
      # 'enum' as a column type in create_table, so we define it as a string
      # and ensure the database column is set to 'role_type'.
      # Alternatively, you can use execute again to alter the column type,
      # but for simplicity, Active Record will often treat it as string internally.
      # The database constraint will enforce the ENUM values.
      t.string :name, null: false # Removed unique: true from here
      # For stricter type matching, you'd typically write a separate execute statement
      # to ALTER TABLE roles ALTER COLUMN name TYPE role_type USING name::role_type;
      # However, Rails' type mapping and database validation usually make this unnecessary
      # if your ENUM values match your string values.

      t.timestamps # Automatically adds created_at and updated_at
    end

    # Add index for the unique constraint (THIS IS WHERE unique: true BELONGS)
    add_index :roles, :name, unique: true

    # For the role_type ENUM to be correctly reflected in db/structure.sql,
    # it needs to be created before the table. The `execute` block handles this.
  end

  # Add a `down` method to revert the ENUM type on rollback
  def down
    # Drop the roles table first
    drop_table :roles

    # Then drop the ENUM type
    execute <<-SQL
      DROP TYPE role_type;
    SQL
  end
end
