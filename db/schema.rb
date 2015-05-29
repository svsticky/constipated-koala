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

ActiveRecord::Schema.define(version: 20150516184235) do

  create_table "activities", force: :cascade do |t|
    t.string   "name",                limit: 255
    t.date     "start_date"
    t.date     "end_date"
    t.decimal  "price",                             precision: 6, scale: 2
    t.text     "comments",            limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "poster_file_name",    limit: 255
    t.string   "poster_content_type", limit: 255
    t.integer  "poster_file_size",    limit: 4
    t.datetime "poster_updated_at"
    t.text     "description",         limit: 65535
  end

  create_table "admins", force: :cascade do |t|
    t.string   "first_name", limit: 255
    t.string   "infix",      limit: 255
    t.string   "last_name",  limit: 255
    t.text     "signature",  limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "advertisements", force: :cascade do |t|
    t.string   "name",                limit: 255
    t.string   "poster_file_name",    limit: 255
    t.string   "poster_content_type", limit: 255
    t.integer  "poster_file_size",    limit: 4
    t.datetime "poster_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "checkout_balances", force: :cascade do |t|
    t.decimal  "balance",              precision: 6, scale: 2
    t.integer  "member_id",  limit: 4,                         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "checkout_cards", force: :cascade do |t|
    t.string   "uuid",                limit: 16,    null: false
    t.text     "description",         limit: 65535
    t.boolean  "active",              limit: 1
    t.integer  "member_id",           limit: 4,     null: false
    t.integer  "checkout_balance_id", limit: 4,     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "checkout_cards", ["uuid"], name: "index_checkout_cards_on_uuid", unique: true, using: :btree

  create_table "checkout_products", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.integer  "category",           limit: 4
    t.boolean  "active",             limit: 1,                           default: true
    t.decimal  "price",                          precision: 6, scale: 2
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size",    limit: 4
    t.datetime "image_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "checkout_transactions", force: :cascade do |t|
    t.decimal  "price",                           precision: 6, scale: 2, null: false
    t.integer  "checkout_card_id",    limit: 4
    t.integer  "checkout_balance_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "items",               limit: 255
  end

  create_table "educations", force: :cascade do |t|
    t.integer  "member_id",  limit: 4
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "study_id",   limit: 4, null: false
    t.integer  "status",     limit: 4
  end

  add_index "educations", ["member_id", "study_id", "start_date"], name: "index_educations_on_member_id_and_study_id_and_start_date", unique: true, using: :btree

  create_table "ideal_transactions", id: false, force: :cascade do |t|
    t.string   "uuid",             limit: 16
    t.integer  "member_id",        limit: 4
    t.string   "transaction_type", limit: 255
    t.string   "transaction_id",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "impressions", force: :cascade do |t|
    t.string   "impressionable_type", limit: 255
    t.integer  "impressionable_id",   limit: 4
    t.integer  "user_id",             limit: 4
    t.string   "controller_name",     limit: 255
    t.string   "action_name",         limit: 255
    t.string   "view_name",           limit: 255
    t.string   "request_hash",        limit: 255
    t.string   "ip_address",          limit: 255
    t.string   "session_hash",        limit: 255
    t.text     "message",             limit: 65535
    t.text     "referrer",            limit: 65535
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

  create_table "members", force: :cascade do |t|
    t.string   "first_name",   limit: 255
    t.string   "infix",        limit: 255
    t.string   "last_name",    limit: 255
    t.string   "address",      limit: 255
    t.string   "house_number", limit: 255
    t.string   "postal_code",  limit: 255
    t.string   "city",         limit: 255
    t.string   "phone_number", limit: 255
    t.string   "email",        limit: 255
    t.string   "gender",       limit: 1
    t.string   "student_id",   limit: 255
    t.date     "birth_date"
    t.date     "join_date"
    t.text     "comments",     limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "members", ["email"], name: "index_members_on_email", unique: true, using: :btree

  create_table "participants", force: :cascade do |t|
    t.integer  "member_id",   limit: 4
    t.integer  "activity_id", limit: 4
    t.decimal  "price",                 precision: 6, scale: 2
    t.boolean  "paid",        limit: 1,                         default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "participants", ["member_id", "activity_id"], name: "index_participants_on_member_id_and_activity_id", unique: true, using: :btree

  create_table "studies", force: :cascade do |t|
    t.string  "name",    limit: 255
    t.string  "code",    limit: 255
    t.boolean "masters", limit: 1
  end

  create_table "tags", id: false, force: :cascade do |t|
    t.integer  "member_id",  limit: 4
    t.integer  "name",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["member_id", "name"], name: "index_tags_on_member_id_and_name", unique: true, using: :btree

  create_table "trigrams", force: :cascade do |t|
    t.string  "trigram",     limit: 3
    t.integer "score",       limit: 2
    t.integer "owner_id",    limit: 4
    t.string  "owner_type",  limit: 255
    t.string  "fuzzy_field", limit: 255
  end

  add_index "trigrams", ["owner_id", "owner_type", "fuzzy_field", "trigram", "score"], name: "index_for_match", using: :btree
  add_index "trigrams", ["owner_id", "owner_type"], name: "index_by_owner", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.integer  "credentials_id",         limit: 4,                null: false
    t.string   "credentials_type",       limit: 255,              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["credentials_id", "credentials_type"], name: "index_users_on_credentials_id_and_credentials_type", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
