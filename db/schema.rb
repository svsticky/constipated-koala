# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_08_25_204709) do

  create_table "active_storage_attachments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata", size: :medium
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "activities", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "name"
    t.date "start_date"
    t.time "start_time"
    t.date "end_date"
    t.time "end_time"
    t.decimal "price", precision: 6, scale: 2
    t.text "comments", size: :medium
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "description", size: :medium
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
    t.boolean "show_on_website", default: false, null: false
  end

  create_table "admins", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "first_name"
    t.string "infix"
    t.string "last_name"
    t.text "signature", size: :medium
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "advertisements", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "checkout_balances", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.decimal "balance", precision: 6, scale: 2, default: "0.0"
    t.integer "member_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "checkout_cards", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "uuid", limit: 16, null: false
    t.text "description", size: :medium
    t.boolean "active", default: false
    t.integer "member_id", null: false
    t.integer "checkout_balance_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "confirmation_token"
    t.index ["uuid"], name: "index_checkout_cards_on_uuid", unique: true
  end

  create_table "checkout_products", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "name"
    t.integer "category"
    t.integer "parent"
    t.boolean "active", default: true
    t.decimal "price", precision: 6, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "checkout_transactions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.decimal "price", precision: 6, scale: 2, null: false
    t.integer "checkout_card_id"
    t.integer "checkout_balance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "items"
    t.string "payment_method", limit: 7
  end

  create_table "educations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "member_id"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "study_id", null: false
    t.integer "status"
    t.index ["member_id", "study_id", "start_date"], name: "index_educations_on_member_id_and_study_id_and_start_date", unique: true
  end

  create_table "group_members", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "member_id"
    t.integer "group_id"
    t.integer "year"
    t.string "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["member_id", "group_id", "year"], name: "index_group_members_on_member_id_and_group_id_and_year", unique: true
  end

  create_table "groups", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "name"
    t.integer "category"
    t.text "comments", size: :medium
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ideal_transactions", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "description"
    t.decimal "amount", precision: 6, scale: 2
    t.string "status", limit: 9, default: "open"
    t.integer "member_id"
    t.string "transaction_type"
    t.string "transaction_id"
    t.string "redirect_uri"
    t.string "trxid"
    t.string "token", limit: 64
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["token"], name: "index_ideal_transactions_on_token", unique: true
    t.index ["trxid"], name: "index_ideal_transactions_on_trxid", unique: true
  end

  create_table "impressions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "impressionable_type"
    t.integer "impressionable_id"
    t.integer "user_id"
    t.string "controller_name"
    t.string "action_name"
    t.string "view_name"
    t.string "request_hash"
    t.string "ip_address"
    t.string "session_hash"
    t.text "message", size: :medium
    t.text "referrer", size: :medium
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "params", size: :medium
    t.index ["controller_name", "action_name", "ip_address"], name: "controlleraction_ip_index"
    t.index ["controller_name", "action_name", "request_hash"], name: "controlleraction_request_index"
    t.index ["controller_name", "action_name", "session_hash"], name: "controlleraction_session_index"
    t.index ["impressionable_type", "impressionable_id", "ip_address"], name: "poly_ip_index"
    t.index ["impressionable_type", "impressionable_id", "params"], name: "poly_params_request_index", length: { params: 100 }
    t.index ["impressionable_type", "impressionable_id", "request_hash"], name: "poly_request_index"
    t.index ["impressionable_type", "impressionable_id", "session_hash"], name: "poly_session_index"
    t.index ["impressionable_type", "message", "impressionable_id"], name: "impressionable_type_message_index", length: { message: 255 }
    t.index ["user_id"], name: "index_impressions_on_user_id"
  end

  create_table "members", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "first_name"
    t.string "infix"
    t.string "last_name"
    t.string "address"
    t.string "house_number"
    t.string "postal_code"
    t.string "city"
    t.string "phone_number"
    t.string "emergency_phone_number"
    t.string "email"
    t.string "student_id"
    t.date "birth_date"
    t.date "join_date"
    t.text "comments", size: :medium
    t.integer "consent", default: 0
    t.date "consent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], name: "index_members_on_email", unique: true
    t.index ["student_id"], name: "index_members_on_student_id", unique: true
  end

  create_table "oauth_access_grants", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.integer "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", size: :medium, null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
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

  create_table "oauth_applications", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", size: :medium, null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "confidential", default: true, null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "oauth_openid_requests", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "access_grant_id", null: false
    t.string "nonce", null: false
    t.index ["access_grant_id"], name: "fk_rails_77114b3b09"
  end

  create_table "participants", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
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

  create_table "settings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "var", null: false
    t.text "value", size: :medium
    t.integer "thing_id"
    t.string "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true
  end

  create_table "studies", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "code"
    t.boolean "masters"
    t.boolean "active", default: true, null: false
  end

  create_table "tags", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "member_id"
    t.integer "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["member_id", "name"], name: "index_tags_on_member_id_and_name", unique: true
  end

  create_table "tokens", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "token", null: false
    t.integer "intent", null: false
    t.string "object_type", null: false
    t.bigint "object_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "expires_at", null: false
    t.index ["object_type", "object_id"], name: "index_tokens_on_object_type_and_object_id"
  end

  create_table "trigrams", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "trigram", limit: 3
    t.integer "score", limit: 2
    t.integer "owner_id"
    t.string "owner_type"
    t.string "fuzzy_field"
    t.index ["owner_id", "owner_type", "fuzzy_field", "trigram", "score"], name: "index_for_match"
    t.index ["owner_id", "owner_type"], name: "index_by_owner"
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
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
    t.string "credentials_type", null: false
    t.integer "credentials_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["credentials_id", "credentials_type"], name: "index_users_on_credentials_id_and_credentials_type", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "oauth_openid_requests", "oauth_access_grants", column: "access_grant_id"
end
