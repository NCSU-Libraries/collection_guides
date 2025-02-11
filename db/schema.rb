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

ActiveRecord::Schema[7.2].define(version: 2025_02_12_191041) do
  create_table "agent_associations", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "record_id"
    t.string "record_type"
    t.integer "agent_id"
    t.string "role"
    t.string "function"
    t.string "relator"
    t.integer "position"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.text "terms", size: :long
    t.index ["agent_id"], name: "index_agent_associations_on_agent_id"
    t.index ["record_id"], name: "index_agent_associations_on_record_id"
    t.index ["record_type"], name: "index_agent_associations_on_record_type"
  end

  create_table "agents", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.string "uri"
    t.string "display_name"
    t.string "agent_type"
    t.text "api_response", size: :long
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["agent_type"], name: "index_agents_on_agent_type"
    t.index ["uri"], name: "index_agents_on_uri"
  end

  create_table "archival_objects", id: :integer, default: nil, charset: "utf8mb3", force: :cascade do |t|
    t.string "uri", null: false
    t.string "title", limit: 8704
    t.boolean "publish"
    t.integer "parent_id"
    t.integer "resource_id"
    t.integer "repository_id", null: false
    t.string "level"
    t.integer "position"
    t.text "api_response", size: :long
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.text "unit_data", size: :long
    t.boolean "has_children"
    t.integer "load_position"
    t.string "component_id"
    t.index ["parent_id"], name: "index_archival_objects_on_parent_id"
    t.index ["repository_id"], name: "index_archival_objects_on_repository_id"
    t.index ["resource_id"], name: "index_archival_objects_on_resource_id"
    t.index ["uri"], name: "index_archival_objects_on_uri"
  end

  create_table "aspace_imports", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "import_type"
    t.integer "resources_updated"
    t.integer "import_errors"
    t.text "resource_list"
  end

  create_table "digital_object_associations", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "record_id"
    t.string "record_type"
    t.integer "digital_object_id"
    t.integer "position"
    t.index ["digital_object_id"], name: "index_digital_object_associations_on_digital_object_id"
    t.index ["record_id"], name: "index_digital_object_associations_on_record_id"
    t.index ["record_type"], name: "index_digital_object_associations_on_record_type"
  end

  create_table "digital_object_volumes", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "digital_object_id", null: false
    t.integer "position", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "volume_id"
  end

  create_table "digital_objects", id: :integer, default: nil, charset: "utf8mb3", force: :cascade do |t|
    t.string "uri", null: false
    t.integer "repository_id", null: false
    t.string "title", limit: 8704
    t.string "digital_object_id"
    t.boolean "publish"
    t.text "api_response", size: :long
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "show_thumbnails"
    t.boolean "has_files"
    t.text "image_data"
    t.index ["uri"], name: "index_digital_objects_on_uri"
  end

  create_table "repositories", id: :integer, default: nil, charset: "utf8mb3", force: :cascade do |t|
    t.string "uri", null: false
    t.string "repo_code", null: false
    t.string "org_code"
    t.string "name", null: false
    t.text "api_response", size: :long
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["repo_code"], name: "index_repositories_on_repo_code"
  end

  create_table "resource_tree_updates", charset: "utf8mb3", force: :cascade do |t|
    t.integer "resource_id"
    t.datetime "completed_at", precision: nil
    t.integer "exit_status"
    t.text "error"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "resource_uri"
  end

  create_table "resources", id: :integer, default: nil, charset: "utf8mb3", force: :cascade do |t|
    t.string "uri", null: false
    t.integer "repository_id", null: false
    t.string "title", limit: 8704
    t.boolean "publish"
    t.text "api_response", size: :long
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.text "unit_data", size: :long
    t.boolean "has_children"
    t.text "structure", size: :long
    t.integer "total_components"
    t.integer "total_top_components"
    t.string "eadid"
    t.index ["eadid"], name: "index_resources_on_eadid"
    t.index ["repository_id"], name: "index_resources_on_repository_id"
    t.index ["uri"], name: "index_resources_on_uri"
  end

  create_table "search_indices", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.string "index_type"
    t.integer "records_updated"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "subject_associations", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "record_id"
    t.string "record_type"
    t.integer "subject_id"
    t.string "function"
    t.integer "position"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["record_id"], name: "index_subject_associations_on_record_id"
    t.index ["record_type"], name: "index_subject_associations_on_record_type"
    t.index ["subject_id"], name: "index_subject_associations_on_subject_id"
  end

  create_table "subjects", id: :integer, default: nil, charset: "utf8mb3", force: :cascade do |t|
    t.string "uri"
    t.string "subject"
    t.string "subject_root"
    t.string "subject_type"
    t.string "subject_source_uri"
    t.text "api_response", size: :long
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["subject_type"], name: "index_subjects_on_subject_type"
    t.index ["uri"], name: "index_subjects_on_uri"
  end

  create_table "users", charset: "utf8mb3", collation: "utf8mb3_bin", force: :cascade do |t|
    t.string "display_name"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end
end
