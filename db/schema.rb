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

ActiveRecord::Schema.define(version: 20180228153049) do

  create_table "activities", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC" do |t|
    t.string "name"
    t.date "start_date"
    t.time "start_time"
    t.date "end_date"
    t.time "end_time"
    t.decimal "price", precision: 6, scale: 2
    t.text "comments", limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "poster_file_name"
    t.string "poster_content_type"
    t.integer "poster_file_size"
    t.datetime "poster_updated_at"
    t.text "description", limit: 16777215
    t.integer "organized_by"
    t.boolean "is_enrollable"
    t.boolean "is_alcoholic"
    t.integer "participant_limit"
    t.string "location"
    t.date "unenroll_date"
    t.string "notes"
    t.boolean "is_viewable"
    t.boolean "notes_mandatory"
    t.boolean "notes_public"
    t.boolean "is_masters"
    t.boolean "is_freshmans"
  end

  create_table "admins", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC" do |t|
    t.string "first_name"
    t.string "infix"
    t.string "last_name"
    t.text "signature", limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "advertisements", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC" do |t|
    t.string "name"
    t.string "poster_file_name"
    t.string "poster_content_type"
    t.integer "poster_file_size"
    t.datetime "poster_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "checkout_balances", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC" do |t|
    t.decimal "balance", precision: 6, scale: 2, default: "0.0"
    t.integer "member_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "checkout_cards", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC" do |t|
    t.string "uuid", limit: 16, null: false
    t.text "description", limit: 16777215
    t.boolean "active", default: false
    t.integer "member_id", null: false
    t.integer "checkout_balance_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "confirmation_token"
    t.index ["uuid"], name: "index_checkout_cards_on_uuid", unique: true
  end

  create_table "checkout_product_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "name"
    t.integer "category"
    t.boolean "active", default: true
    t.decimal "price", precision: 6, scale: 2
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "checkout_products", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC" do |t|
    t.string "name"
    t.integer "category"
    t.integer "parent"
    t.boolean "active", default: true
    t.decimal "price", precision: 6, scale: 2
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "storage_stock", default: 0
    t.integer "chamber_stock", default: 0
    t.bigint "checkout_product_type_id"
    t.index ["checkout_product_type_id"], name: "index_checkout_products_on_checkout_product_type_id"
  end

  create_table "checkout_transaction_items", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.bigint "checkout_transaction_id"
    t.bigint "checkout_product_type_id"
    t.decimal "price", precision: 6, scale: 2
    t.index ["checkout_product_type_id"], name: "index_checkout_transaction_items_on_checkout_product_type_id"
    t.index ["checkout_transaction_id"], name: "index_checkout_transaction_items_on_checkout_transaction_id"
  end

  create_table "checkout_transactions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC" do |t|
    t.decimal "price", precision: 6, scale: 2, null: false
    t.integer "checkout_card_id"
    t.integer "checkout_balance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "items"
    t.string "payment_method", limit: 7
  end

  create_table "educations", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC" do |t|
    t.integer "member_id"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "study_id", null: false
    t.integer "status"
    t.index ["member_id", "study_id", "start_date"], name: "index_educations_on_member_id_and_study_id_and_start_date", unique: true
  end

  create_table "group_members", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC" do |t|
    t.integer "member_id"
    t.integer "group_id"
    t.integer "year"
    t.string "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["member_id", "group_id", "year"], name: "index_group_members_on_member_id_and_group_id_and_year", unique: true
  end

  create_table "groups", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC" do |t|
    t.string "name"
    t.integer "category"
    t.text "comments", limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ideal_transactions", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC" do |t|
    t.string "description"
    t.decimal "amount", precision: 6, scale: 2
    t.string "status", limit: 9, default: "open"
    t.integer "member_id"
    t.string "transaction_type"
    t.string "transaction_id"
    t.string "redirect_uri"
    t.string "token", limit: 64
    t.string "trxid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["token"], name: "index_ideal_transactions_on_token", unique: true
    t.index ["trxid"], name: "index_ideal_transactions_on_trxid", unique: true
  end

  create_table "impressions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC" do |t|
    t.string "impressionable_type"
    t.integer "impressionable_id"
    t.integer "user_id"
    t.string "controller_name"
    t.string "action_name"
    t.string "view_name"
    t.string "request_hash"
    t.string "ip_address"
    t.string "session_hash"
    t.text "message", limit: 16777215
    t.text "referrer", limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "params", limit: 16777215
    t.index ["controller_name", "action_name", "ip_address"], name: "controlleraction_ip_index", length: { controller_name: 191, action_name: 191, ip_address: 191 }
    t.index ["controller_name", "action_name", "request_hash"], name: "controlleraction_request_index", length: { controller_name: 191, action_name: 191, request_hash: 191 }
    t.index ["controller_name", "action_name", "session_hash"], name: "controlleraction_session_index", length: { controller_name: 191, action_name: 191, session_hash: 191 }
    t.index ["impressionable_type", "impressionable_id", "ip_address"], name: "poly_ip_index", length: { impressionable_type: 191, ip_address: 191 }
    t.index ["impressionable_type", "impressionable_id", "params"], name: "poly_params_request_index", length: { impressionable_type: 191, params: 100 }
    t.index ["impressionable_type", "impressionable_id", "request_hash"], name: "poly_request_index", length: { impressionable_type: 191, request_hash: 191 }
    t.index ["impressionable_type", "impressionable_id", "session_hash"], name: "poly_session_index", length: { impressionable_type: 191, session_hash: 191 }
    t.index ["impressionable_type", "message", "impressionable_id"], name: "impressionable_type_message_index", length: { impressionable_type: 191, message: 191 }
    t.index ["user_id"], name: "index_impressions_on_user_id"
  end

  create_table "members", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC" do |t|
    t.string "first_name"
    t.string "infix"
    t.string "last_name"
    t.string "address"
    t.string "house_number"
    t.string "postal_code"
    t.string "city"
    t.string "phone_number"
    t.string "email"
    t.string "gender", limit: 1
    t.string "student_id"
    t.date "birth_date"
    t.date "join_date"
    t.text "comments", limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], name: "index_members_on_email", unique: true
    t.index ["student_id"], name: "index_members_on_student_id", unique: true
  end

  create_table "oauth_access_grants", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC" do |t|
    t.integer "resource_owner_id", null: false
    t.integer "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", limit: 16777215, null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC" do |t|
    t.integer "resource_owner_id"
    t.integer "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC" do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", limit: 16777215, null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "participants", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC" do |t|
    t.integer "member_id"
    t.integer "activity_id"
    t.decimal "price", precision: 6, scale: 2
    t.boolean "paid", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "reservist", default: false
    t.string "notes", limit: 30
    t.index ["member_id", "activity_id"], name: "index_participants_on_member_id_and_activity_id", unique: true
  end

  create_table "settings", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC" do |t|
    t.string "var", null: false
    t.text "value", limit: 16777215
    t.integer "thing_id"
    t.string "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true
  end

  create_table "stocky_transactions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "amount", null: false
    t.string "from", null: false
    t.string "to", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "checkout_product_id"
    t.decimal "price", precision: 10
    t.index ["checkout_product_id"], name: "index_stocky_transactions_on_checkout_product_id"
  end

  create_table "studies", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC" do |t|
    t.string "code"
    t.boolean "masters"
    t.boolean "active", default: true, null: false
  end

  create_table "tags", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC" do |t|
    t.integer "member_id"
    t.integer "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["member_id", "name"], name: "index_tags_on_member_id_and_name", unique: true
  end

  create_table "trigrams", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC" do |t|
    t.string "trigram", limit: 3
    t.integer "score", limit: 2
    t.integer "owner_id"
    t.string "owner_type"
    t.string "fuzzy_field"
    t.index ["owner_id", "owner_type", "fuzzy_field", "trigram", "score"], name: "index_for_match"
    t.index ["owner_id", "owner_type"], name: "index_by_owner"
  end

  create_table "users", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC" do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "credentials_id", null: false
    t.string "credentials_type", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["credentials_id", "credentials_type"], name: "index_users_on_credentials_id_and_credentials_type", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
