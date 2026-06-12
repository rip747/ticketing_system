class AddSysAdminRole < ActiveRecord::Migration[8.1]
  def change
    # Make organization_id nullable so sys_admins can exist without an org
    change_column_null :users, :organization_id, true
  end
end
