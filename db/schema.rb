# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20171010210428) do

  create_table "agent_associations", force: :cascade do |t|
    t.integer  "record_id",   limit: 4
    t.string   "record_type", limit: 255
    t.integer  "agent_id",    limit: 4
    t.string   "role",        limit: 255
    t.string   "function",    limit: 255
    t.string   "relator",     limit: 255
    t.integer  "position",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "terms",       limit: 4294967295
  end

  add_index "agent_associations", ["agent_id"], name: "index_agent_associations_on_agent_id"
  add_index "agent_associations", ["record_id"], name: "index_agent_associations_on_record_id"
  add_index "agent_associations", ["record_type"], name: "index_agent_associations_on_record_type"

  create_table "agents", force: :cascade do |t|
    t.string   "uri",          limit: 255
    t.string   "display_name", limit: 255
    t.string   "agent_type",   limit: 255
    t.text     "api_response", limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "agents", ["agent_type"], name: "index_agents_on_agent_type"
  add_index "agents", ["uri"], name: "index_agents_on_uri"

  create_table "archival_objects", force: :cascade do |t|
    t.string   "uri",           limit: 255,        null: false
    t.string   "title",         limit: 8704
    t.boolean  "publish"
    t.integer  "parent_id",     limit: 4
    t.integer  "resource_id",   limit: 4
    t.integer  "repository_id", limit: 4,          null: false
    t.string   "level",         limit: 255
    t.integer  "position",      limit: 4
    t.text     "api_response",  limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "unit_data",     limit: 4294967295
    t.boolean  "has_children"
    t.integer  "load_position", limit: 4
    t.string   "component_id",  limit: 255
  end

  add_index "archival_objects", ["parent_id"], name: "index_archival_objects_on_parent_id"
  add_index "archival_objects", ["repository_id"], name: "index_archival_objects_on_repository_id"
  add_index "archival_objects", ["resource_id"], name: "index_archival_objects_on_resource_id"
  add_index "archival_objects", ["uri"], name: "index_archival_objects_on_uri"

  create_table "aspace_imports", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "import_type",              limit: 255
    t.integer  "resources_updated",        limit: 4
    t.integer  "archival_objects_updated", limit: 4
  end

  create_table "digital_object_associations", force: :cascade do |t|
    t.integer "record_id",         limit: 4
    t.string  "record_type",       limit: 255
    t.integer "digital_object_id", limit: 4
    t.integer "position",          limit: 4
  end

  add_index "digital_object_associations", ["digital_object_id"], name: "index_digital_object_associations_on_digital_object_id"
  add_index "digital_object_associations", ["record_id"], name: "index_digital_object_associations_on_record_id"
  add_index "digital_object_associations", ["record_type"], name: "index_digital_object_associations_on_record_type"

  create_table "digital_object_volumes", force: :cascade do |t|
    t.integer  "digital_object_id", limit: 4, null: false
    t.integer  "position",          limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "volume_id",         limit: 4
  end

  create_table "digital_objects", force: :cascade do |t|
    t.string   "uri",               limit: 255,        null: false
    t.integer  "repository_id",     limit: 4,          null: false
    t.string   "title",             limit: 8704
    t.string   "digital_object_id", limit: 255
    t.boolean  "publish"
    t.text     "api_response",      limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "show_thumbnails"
    t.boolean  "has_files"
  end

  add_index "digital_objects", ["uri"], name: "index_digital_objects_on_uri"

  create_table "repositories", force: :cascade do |t|
    t.string   "uri",          limit: 255,        null: false
    t.string   "repo_code",    limit: 255,        null: false
    t.string   "org_code",     limit: 255
    t.string   "name",         limit: 255,        null: false
    t.text     "api_response", limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "repositories", ["repo_code"], name: "index_repositories_on_repo_code"

  create_table "resources", force: :cascade do |t|
    t.string   "uri",                  limit: 255,        null: false
    t.integer  "repository_id",        limit: 4,          null: false
    t.string   "title",                limit: 8704
    t.boolean  "publish"
    t.text     "api_response",         limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "unit_data",            limit: 4294967295
    t.boolean  "has_children"
    t.text     "structure",            limit: 4294967295
    t.integer  "total_components",     limit: 4
    t.integer  "total_top_components", limit: 4
    t.string   "eadid",                limit: 255
  end

  add_index "resources", ["eadid"], name: "index_resources_on_eadid"
  add_index "resources", ["repository_id"], name: "index_resources_on_repository_id"
  add_index "resources", ["uri"], name: "index_resources_on_uri"

  create_table "search_indices", force: :cascade do |t|
    t.string   "index_type",      limit: 255
    t.integer  "records_updated", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subject_associations", force: :cascade do |t|
    t.integer  "record_id",   limit: 4
    t.string   "record_type", limit: 255
    t.integer  "subject_id",  limit: 4
    t.string   "function",    limit: 255
    t.integer  "position",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subject_associations", ["record_id"], name: "index_subject_associations_on_record_id"
  add_index "subject_associations", ["record_type"], name: "index_subject_associations_on_record_type"
  add_index "subject_associations", ["subject_id"], name: "index_subject_associations_on_subject_id"

  create_table "subjects", force: :cascade do |t|
    t.string   "uri",                limit: 255
    t.string   "subject",            limit: 255
    t.string   "subject_root",       limit: 255
    t.string   "subject_type",       limit: 255
    t.string   "subject_source_uri", limit: 255
    t.text     "api_response",       limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subjects", ["subject_type"], name: "index_subjects_on_subject_type"
  add_index "subjects", ["uri"], name: "index_subjects_on_uri"

end
