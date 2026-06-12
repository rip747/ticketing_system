class UpdateEmailUniqueIndexForTenant < ActiveRecord::Migration[8.1]
  def change
    # Remove the global unique index on email
    remove_index :users, :email, unique: true

    # Add composite unique index scoped to organization
    add_index :users, [ :organization_id, :email ], unique: true
  end
end
