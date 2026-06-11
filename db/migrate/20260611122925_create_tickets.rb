class CreateTickets < ActiveRecord::Migration[8.1]
  def change
    create_table :tickets do |t|
      t.string :subject, null: false
      t.text :description
      t.string :status, null: false, default: "open"
      t.string :priority, null: false, default: "medium"
      t.references :user, null: false, foreign_key: true
      t.references :assigned_user, foreign_key: { to_table: :users }
      t.references :category, null: false, foreign_key: true
      t.references :department, null: false, foreign_key: true
      t.datetime :closed_at

      t.timestamps
    end

    add_index :tickets, :status
    add_index :tickets, :priority
  end
end
