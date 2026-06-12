class AddOrganizationToDepartments < ActiveRecord::Migration[8.1]
  def change
    add_reference :departments, :organization, foreign_key: true

    reversible do |dir|
      dir.up do
        result = exec_query("SELECT id FROM organizations WHERE slug = 'default'")
        default_id = result.rows.first[0]
        exec_query("UPDATE departments SET organization_id = #{default_id} WHERE organization_id IS NULL")
        change_column_null :departments, :organization_id, false
      end
    end
  end
end
