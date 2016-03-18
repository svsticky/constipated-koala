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

ActiveRecord::Schema.define(version: 20160301185508) do

  create_table "activities", force: true do |t|
    t.string   "name"
    t.date     "start_date"
    t.date     "end_date"
    t.decimal  "price",               precision: 6, scale: 2
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "poster_file_name"
    t.string   "poster_content_type"
    t.integer  "poster_file_size"
    t.datetime "poster_updated_at"
    t.text     "description"
    t.integer  "organized_by"
  end

  create_table "admins", force: true do |t|
    t.string   "first_name"
    t.string   "infix"
    t.string   "last_name"
    t.text     "signature"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "advertisements", force: true do |t|
    t.string   "name"
    t.string   "poster_file_name"
    t.string   "poster_content_type"
    t.integer  "poster_file_size"
    t.datetime "poster_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "checkout_balances", force: true do |t|
    t.decimal  "balance",    precision: 6, scale: 2
    t.integer  "member_id",                          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "checkout_cards", force: true do |t|
    t.string   "uuid",                limit: 16, null: false
    t.text     "description"
    t.boolean  "active"
    t.integer  "member_id",                      null: false
    t.integer  "checkout_balance_id",            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "checkout_cards", ["uuid"], name: "index_checkout_cards_on_uuid", unique: true, using: :btree

  create_table "checkout_products", force: true do |t|
    t.string   "name"
    t.integer  "category"
    t.integer  "parent"
    t.boolean  "active",                                     default: true
    t.decimal  "price",              precision: 6, scale: 2
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "checkout_transactions", force: true do |t|
    t.decimal  "price",               precision: 6, scale: 2, null: false
    t.integer  "checkout_card_id"
    t.integer  "checkout_balance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "items"
  end

  create_table "educations", force: true do |t|
    t.integer  "member_id"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "study_id",   null: false
    t.integer  "status"
  end

  add_index "educations", ["member_id", "study_id", "start_date"], name: "index_educations_on_member_id_and_study_id_and_start_date", unique: true, using: :btree

  create_table "group_members", force: true do |t|
    t.integer  "member_id"
    t.integer  "group_id"
    t.integer  "year"
    t.string   "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_members", ["member_id", "group_id", "year"], name: "index_group_members_on_member_id_and_group_id_and_year", unique: true, using: :btree

  create_table "groups", force: true do |t|
    t.string   "name"
    t.integer  "category"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ideal_transactions", id: false, force: true do |t|
    t.string   "uuid",             limit: 16
    t.integer  "member_id"
    t.string   "transaction_type"
    t.string   "transaction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "impressions", force: true do |t|
    t.string   "impressionable_type"
    t.integer  "impressionable_id"
    t.integer  "user_id"
    t.string   "controller_name"
    t.string   "action_name"
    t.string   "view_name"
    t.string   "request_hash"
    t.string   "ip_address"
    t.string   "session_hash"
    t.text     "message"
    t.text     "referrer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "impressions", ["controller_name", "action_name", "ip_address"], name: "controlleraction_ip_index", using: :btree
  add_index "impressions", ["controller_name", "action_name", "request_hash"], name: "controlleraction_request_index", using: :btree
  add_index "impressions", ["controller_name", "action_name", "session_hash"], name: "controlleraction_session_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "ip_address"], name: "poly_ip_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "request_hash"], name: "poly_request_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "session_hash"], name: "poly_session_index", using: :btree
  add_index "impressions", ["impressionable_type", "message", "impressionable_id"], name: "impressionable_type_message_index", length: {"impressionable_type"=>nil, "message"=>255, "impressionable_id"=>nil}, using: :btree
  add_index "impressions", ["user_id"], name: "index_impressions_on_user_id", using: :btree

  create_table "members", force: true do |t|
    t.string   "first_name"
    t.string   "infix"
    t.string   "last_name"
    t.string   "address"
    t.string   "house_number"
    t.string   "postal_code"
    t.string   "city"
    t.string   "phone_number"
    t.string   "email"
    t.string   "gender",       limit: 1
    t.string   "student_id"
    t.date     "birth_date"
    t.date     "join_date"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "members", ["email"], name: "index_members_on_email", unique: true, using: :btree
  add_index "members", ["student_id"], name: "index_members_on_student_id", unique: true, using: :btree

  create_table "oauth_access_grants", force: true do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.text     "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: true do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",             null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        null: false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: true do |t|
    t.string   "name",                         null: false
    t.string   "uid",                          null: false
    t.string   "secret",                       null: false
    t.text     "redirect_uri",                 null: false
    t.string   "scopes",       default: "",    null: false
    t.boolean  "trusted",      default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "participants", force: true do |t|
    t.integer  "member_id"
    t.integer  "activity_id"
    t.decimal  "price",       precision: 6, scale: 2
    t.boolean  "paid",                                default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "participants", ["member_id", "activity_id"], name: "index_participants_on_member_id_and_activity_id", unique: true, using: :btree

  create_table "settings", force: true do |t|
    t.string   "var",                   null: false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree

  create_table "studies", force: true do |t|
    t.string  "code"
    t.boolean "masters"
    t.boolean "active",  default: true, null: false
  end

  create_table "tags", id: false, force: true do |t|
    t.integer  "member_id"
    t.integer  "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["member_id", "name"], name: "index_tags_on_member_id_and_name", unique: true, using: :btree

  create_table "trigrams", force: true do |t|
    t.string  "trigram",     limit: 3
    t.integer "score",       limit: 2
    t.integer "owner_id"
    t.string  "owner_type"
    t.string  "fuzzy_field"
  end

  add_index "trigrams", ["owner_id", "owner_type", "fuzzy_field", "trigram", "score"], name: "index_for_match", using: :btree
  add_index "trigrams", ["owner_id", "owner_type"], name: "index_by_owner", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "credentials_id",                      null: false
    t.string   "credentials_type",                    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["credentials_id", "credentials_type"], name: "index_users_on_credentials_id_and_credentials_type", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
