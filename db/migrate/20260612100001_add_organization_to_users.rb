class AddOrganizationToUsers < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :organization, foreign_key: true

    reversible do |dir|
      dir.up do
        # Create default organization for existing records if it doesn't exist
        default_id = nil
        result = exec_query("SELECT id FROM organizations WHERE slug = 'default'")
        if result.rows.any?
          default_id = result.rows.first[0]
        else
          exec_query("INSERT INTO organizations (name, slug, created_at, updated_at) VALUES ('Default Organization', 'default', datetime('now'), datetime('now'))")
          result = exec_query("SELECT id FROM organizations WHERE slug = 'default'")
          default_id = result.rows.first[0]
        end

        exec_query("UPDATE users SET organization_id = #{default_id} WHERE organization_id IS NULL")
        change_column_null :users, :organization_id, false
      end
    end
  end
end
