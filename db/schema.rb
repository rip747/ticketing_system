# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_12_100007) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "department_id", null: false
    t.text "description"
    t.string "name"
    t.integer "organization_id", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_categories_on_department_id"
    t.index ["organization_id"], name: "index_categories_on_organization_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.integer "organization_id", null: false
    t.integer "ticket_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["organization_id"], name: "index_comments_on_organization_id"
    t.index ["ticket_id"], name: "index_comments_on_ticket_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "departments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.integer "organization_id", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_departments_on_organization_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_organizations_on_slug", unique: true
  end

  create_table "tickets", force: :cascade do |t|
    t.integer "assigned_user_id"
    t.integer "category_id", null: false
    t.datetime "closed_at"
    t.datetime "created_at", null: false
    t.integer "department_id", null: false
    t.text "description"
    t.integer "organization_id", null: false
    t.string "priority", default: "medium", null: false
    t.string "status", default: "open", null: false
    t.string "subject", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["assigned_user_id"], name: "index_tickets_on_assigned_user_id"
    t.index ["category_id"], name: "index_tickets_on_category_id"
    t.index ["department_id"], name: "index_tickets_on_department_id"
    t.index ["organization_id"], name: "index_tickets_on_organization_id"
    t.index ["priority"], name: "index_tickets_on_priority"
    t.index ["status"], name: "index_tickets_on_status"
    t.index ["user_id"], name: "index_tickets_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "department_id"
    t.string "email", null: false
    t.string "name", null: false
    t.integer "organization_id"
    t.string "password_digest", null: false
    t.string "role", default: "customer", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_users_on_department_id"
    t.index ["organization_id", "email"], name: "index_users_on_organization_id_and_email", unique: true
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "categories", "departments"
  add_foreign_key "categories", "organizations"
  add_foreign_key "comments", "organizations"
  add_foreign_key "comments", "tickets"
  add_foreign_key "comments", "users"
  add_foreign_key "departments", "organizations"
  add_foreign_key "tickets", "categories"
  add_foreign_key "tickets", "departments"
  add_foreign_key "tickets", "organizations"
  add_foreign_key "tickets", "users"
  add_foreign_key "tickets", "users", column: "assigned_user_id"
  add_foreign_key "users", "departments"
  add_foreign_key "users", "organizations"
end
