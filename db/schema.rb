# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_02_19_203654) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "comments", force: :cascade do |t|
    t.integer "entry_id"
    t.string "user_uid"
    t.text "comment"
    t.string "reply_to"
    t.boolean "deleted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entry_id"], name: "index_comments_on_entry_id"
  end

  create_table "entries", force: :cascade do |t|
    t.string "owner_uid"
    t.string "creator_uid"
    t.integer "group_id"
    t.string "title"
    t.text "description"
    t.string "tags", array: true
    t.string "classes", array: true
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "watchers", default: [], array: true
    t.string "assignees", default: [], array: true
    t.index ["assignees"], name: "index_entries_on_assignees"
    t.index ["classes"], name: "index_entries_on_classes", using: :gin
    t.index ["creator_uid"], name: "index_entries_on_creator_uid"
    t.index ["group_id"], name: "index_entries_on_group_id"
    t.index ["owner_uid"], name: "index_entries_on_owner_uid"
    t.index ["tags"], name: "index_entries_on_tags", using: :gin
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "user_id"
    t.string "parent"
    t.string "ctx"
    t.jsonb "messages"
    t.boolean "is_read"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent"], name: "index_notifications_on_parent"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_groups", force: :cascade do |t|
    t.string "owner_uid"
    t.string "name"
    t.jsonb "access"
    t.jsonb "settings"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_uid"], name: "index_user_groups_on_owner_uid"
  end

  create_table "user_models", force: :cascade do |t|
    t.string "owner_uid"
    t.integer "group_id"
    t.string "title"
    t.jsonb "config"
    t.string "unique_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_user_models_on_group_id"
    t.index ["owner_uid"], name: "index_user_models_on_owner_uid"
  end

  create_table "user_settings", force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.jsonb "setting"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_settings_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "uid"
    t.string "alias"
    t.string "email"
    t.boolean "confirmed"
    t.boolean "disabled"
    t.string "disabled_message"
    t.boolean "admin"
    t.string "encrypted_password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email"
  end

end
