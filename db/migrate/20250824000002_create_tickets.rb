class CreateTickets < ActiveRecord::Migration[8.0]
  def change
    create_table :tickets do |t|
      t.string :title, null: false
      t.text :description
      t.string :priority, null: false
      t.string :status, null: false, default: "open"
      t.references :user, null: false, foreign_key: true
      t.references :tenant, null: false, foreign_key: true
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
