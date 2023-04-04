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

ActiveRecord::Schema[7.0].define(version: 2023_03_29_091927) do
  create_table "accounts", id: :bigint, default: nil, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "client_id"
    t.bigint "card_id", null: false
    t.bigint "merchant_id", null: false
    t.bigint "member_id", null: false
    t.string "account_status"
    t.timestamp "open_date"
    t.timestamp "close_date"
    t.decimal "credit_limit", precision: 10
    t.decimal "balance", precision: 10
    t.decimal "available_funds", precision: 10
    t.timestamp "created_at", null: false
    t.timestamp "updated_at", null: false
    t.index ["card_id"], name: "index_accounts_on_card_id"
    t.index ["client_id"], name: "index_accounts_on_client_id"
    t.index ["member_id"], name: "index_accounts_on_member_id"
    t.index ["merchant_id"], name: "index_accounts_on_merchant_id"
  end

  create_table "activities", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "action_type"
    t.string "entered_by"
    t.datetime "alert_created_at"
    t.bigint "user_id"
    t.bigint "alert_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_id"], name: "index_activities_on_alert_id"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "activities_archive", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "action_type"
    t.string "entered_by"
    t.datetime "alert_created_at"
    t.bigint "user_id"
    t.bigint "alert_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_id"], name: "index_activities_archive_on_alert_id"
    t.index ["user_id"], name: "index_activities_archive_on_user_id"
  end

  create_table "activities_archive_out", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "action_type"
    t.string "entered_by"
    t.datetime "alert_created_at"
    t.bigint "user_id"
    t.bigint "alert_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_id"], name: "index_activities_archive_out_on_alert_id"
    t.index ["user_id"], name: "index_activities_archive_out_on_user_id"
  end

  create_table "activities_out", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "action_type"
    t.string "entered_by"
    t.datetime "alert_created_at"
    t.bigint "user_id"
    t.bigint "alert_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_id"], name: "index_activities_out_on_alert_id"
    t.index ["user_id"], name: "index_activities_out_on_user_id"
  end

  create_table "agnostic_fields", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name_from_switch"
    t.string "name"
    t.string "description"
    t.string "data_type", default: "string"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_agnostic_fields_on_name", unique: true
    t.index ["name_from_switch"], name: "index_agnostic_fields_on_name_from_switch", unique: true
  end

  create_table "alert_overrides", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "override_card_id"
    t.bigint "override_type_id"
    t.string "owner_type"
    t.bigint "owner_id"
    t.text "comment"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "updated_by"
    t.string "reason_code"
    t.string "initiated_by"
    t.boolean "active"
    t.string "temp_id"
    t.index ["active"], name: "index_alert_overrides_on_active"
    t.index ["end_time"], name: "index_alert_overrides_on_end_time"
    t.index ["override_card_id"], name: "index_alert_overrides_on_override_card_id"
    t.index ["override_type_id"], name: "index_alert_overrides_on_override_type_id"
    t.index ["owner_id"], name: "index_alert_overrides_on_owner_id"
    t.index ["owner_type", "owner_id"], name: "index_alert_overrides_on_owner"
    t.index ["start_time"], name: "index_alert_overrides_on_start_time"
    t.index ["temp_id"], name: "index_alert_overrides_on_temp_id"
  end

  create_table "alerts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "alert_type"
    t.string "subject"
    t.string "response"
    t.integer "priority"
    t.string "customer_merchant_name"
    t.datetime "run_date"
    t.datetime "examined_on"
    t.datetime "allocated_on"
    t.boolean "examined", default: false
    t.boolean "being_examined", default: false, null: false
    t.boolean "reminder_unactioned", default: false, null: false
    t.string "alert_owner_type"
    t.bigint "alert_owner_id"
    t.bigint "user_id"
    t.bigint "merchant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_owner_id"], name: "index_alerts_on_alert_owner_id"
    t.index ["alert_owner_type", "alert_owner_id", "user_id"], name: "index_alerts_on_owner_and_user"
    t.index ["alert_owner_type", "alert_owner_id"], name: "index_alerts_on_alert_owner"
    t.index ["id"], name: "index_alerts_on_id"
    t.index ["merchant_id"], name: "index_alerts_on_merchant_id"
    t.index ["user_id"], name: "index_alerts_on_user_id"
  end

  create_table "alerts_archive", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "alert_type"
    t.string "subject"
    t.string "response"
    t.integer "priority"
    t.string "customer_merchant_name"
    t.datetime "run_date"
    t.datetime "examined_on"
    t.datetime "allocated_on"
    t.boolean "examined", default: false
    t.boolean "being_examined", default: false, null: false
    t.boolean "reminder_unactioned", default: false, null: false
    t.string "alert_owner_type"
    t.bigint "alert_owner_id"
    t.bigint "user_id"
    t.bigint "merchant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_owner_type", "alert_owner_id"], name: "index_alerts_archive_on_alert_owner"
    t.index ["merchant_id"], name: "index_alerts_archive_on_merchant_id"
    t.index ["user_id"], name: "index_alerts_archive_on_user_id"
  end

  create_table "alerts_archive_out", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "alert_type"
    t.string "subject"
    t.string "response"
    t.integer "priority"
    t.string "customer_merchant_name"
    t.datetime "run_date"
    t.datetime "examined_on"
    t.datetime "allocated_on"
    t.boolean "examined", default: false
    t.boolean "being_examined", default: false, null: false
    t.boolean "reminder_unactioned", default: false, null: false
    t.string "alert_owner_type"
    t.bigint "alert_owner_id"
    t.bigint "user_id"
    t.bigint "merchant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_owner_type", "alert_owner_id"], name: "index_alerts_archive_out_on_alert_owner"
    t.index ["merchant_id"], name: "index_alerts_archive_out_on_merchant_id"
    t.index ["user_id"], name: "index_alerts_archive_out_on_user_id"
  end

  create_table "alerts_out", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "alert_type"
    t.string "subject"
    t.string "response"
    t.integer "priority"
    t.string "customer_merchant_name"
    t.datetime "run_date"
    t.datetime "examined_on"
    t.datetime "allocated_on"
    t.boolean "examined", default: false
    t.boolean "being_examined", default: false, null: false
    t.boolean "reminder_unactioned", default: false, null: false
    t.string "alert_owner_type"
    t.bigint "alert_owner_id"
    t.bigint "user_id"
    t.bigint "merchant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_owner_id"], name: "index_alerts_out_on_alert_owner_id"
    t.index ["alert_owner_type", "alert_owner_id", "user_id"], name: "index_alerts_out_on_owner_and_user"
    t.index ["alert_owner_type", "alert_owner_id"], name: "index_alerts_out_on_alert_owner"
    t.index ["id"], name: "index_alerts_out_on_id"
    t.index ["merchant_id"], name: "index_alerts_out_on_merchant_id"
    t.index ["user_id"], name: "index_alerts_out_on_user_id"
  end

  create_table "authorisation_extras", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "val_string"
    t.integer "val_int"
    t.datetime "val_date"
    t.decimal "val_curr", precision: 22, scale: 4
    t.bigint "agnostic_field_id"
    t.bigint "authorisation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agnostic_field_id"], name: "index_authorisation_extras_on_agnostic_field_id"
    t.index ["authorisation_id", "agnostic_field_id"], name: "auth_fields"
    t.index ["authorisation_id"], name: "index_authorisation_extras_on_authorisation_id"
  end

  create_table "authorisation_extras_archive", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "val_string"
    t.integer "val_int"
    t.datetime "val_date"
    t.decimal "val_curr", precision: 22, scale: 4
    t.bigint "agnostic_field_id"
    t.bigint "authorisation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agnostic_field_id"], name: "index_authorisation_extras_archive_on_agnostic_field_id"
    t.index ["authorisation_id"], name: "index_authorisation_extras_archive_on_authorisation_id"
  end

  create_table "authorisation_extras_archive_out", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "val_string"
    t.integer "val_int"
    t.datetime "val_date"
    t.decimal "val_curr", precision: 22, scale: 4
    t.bigint "agnostic_field_id"
    t.bigint "authorisation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agnostic_field_id"], name: "index_authorisation_extras_archive_out_on_agnostic_field_id"
    t.index ["authorisation_id"], name: "index_authorisation_extras_archive_out_on_authorisation_id"
  end

  create_table "authorisation_extras_out", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "val_string"
    t.integer "val_int"
    t.datetime "val_date"
    t.decimal "val_curr", precision: 22, scale: 4
    t.bigint "agnostic_field_id"
    t.bigint "authorisation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agnostic_field_id"], name: "index_authorisation_extras_out_on_agnostic_field_id"
    t.index ["authorisation_id", "agnostic_field_id"], name: "auth_out_fields"
    t.index ["authorisation_id"], name: "index_authorisation_extras_out_on_authorisation_id"
  end

  create_table "authorisations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "derived_transaction_type"
    t.string "card_name", limit: 128
    t.string "card_type", limit: 50
    t.string "card_number", limit: 128
    t.string "card_issuer", limit: 128
    t.string "card_issuer_country", limit: 50
    t.string "card_class", limit: 20
    t.datetime "expiration_date"
    t.string "auth_code", limit: 20
    t.string "cv2_check_result", limit: 20
    t.string "address_numeric_check_result", limit: 20
    t.string "post_code_check_result", limit: 20
    t.string "secure_3d_auth_check_result", limit: 20
    t.string "address"
    t.string "city", limit: 128
    t.string "post_code", limit: 50
    t.string "county", limit: 128
    t.string "country", limit: 50
    t.string "email", limit: 100
    t.string "phone_number", limit: 30
    t.string "customer_ip_address", limit: 45
    t.decimal "authorisation_amount", precision: 10
    t.decimal "{:scale=>2, :precision=>22}", precision: 10
    t.decimal "local_amount", precision: 10
    t.decimal "{:scale=>2, :precision=>22, :is_indexed=>true}", precision: 10
    t.string "auth_response", limit: 20
    t.string "auth_status", limit: 20
    t.string "transaction_type", limit: 50
    t.string "mcc", limit: 20
    t.string "ccy", limit: 10
    t.string "pos_entry_mode", limit: 1000
    t.integer "pos_condition_code"
    t.string "card_acceptor_business_code", limit: 1000
    t.integer "approval_code_length", limit: 1
    t.string "retrieval_reference_number", limit: 12
    t.string "approval_code", limit: 6
    t.string "response_code", limit: 2
    t.string "card_acceptor_terminal_id", limit: 16
    t.string "card_acceptor_id_code", limit: 15
    t.string "payee", limit: 25
    t.string "card_acceptor_name_location", limit: 1000
    t.bigint "processing_code"
    t.string "currency_code_billing", limit: 3
    t.string "additional_data_private", limit: 1000
    t.string "sys_trace_audit_number", limit: 6
    t.string "order_key"
    t.string "order_description", limit: 256
    t.string "message"
    t.string "jpos_auth_key"
    t.string "jpos_merchant_key"
    t.datetime "auth_date"
    t.datetime "transaction_datetime"
    t.bigint "card_id"
    t.bigint "account_id"
    t.bigint "member_id"
    t.bigint "merchant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "processing_host"
    t.bigint "client_id"
    t.string "jpos_client_key"
    t.string "jpos_member_key"
    t.string "user_string_1"
    t.string "user_string_2"
    t.string "user_string_3"
    t.string "user_string_4"
    t.string "user_string_5"
    t.string "user_string_6"
    t.string "user_string_7"
    t.string "user_string_8"
    t.string "user_string_9"
    t.string "user_string_10"
    t.decimal "user_number_1", precision: 22, scale: 4
    t.decimal "user_number_2", precision: 22, scale: 4
    t.decimal "user_number_3", precision: 22, scale: 4
    t.decimal "user_number_4", precision: 22, scale: 4
    t.decimal "user_number_5", precision: 22, scale: 4
    t.decimal "user_number_6", precision: 22, scale: 4
    t.decimal "user_number_7", precision: 22, scale: 4
    t.decimal "user_number_9", precision: 22, scale: 4
    t.decimal "user_number_8", precision: 22, scale: 4
    t.decimal "user_number_10", precision: 22, scale: 4
    t.datetime "user_date_1"
    t.datetime "user_date_2"
    t.datetime "user_date_3"
    t.datetime "user_date_4"
    t.datetime "user_date_5"
    t.datetime "user_date_6"
    t.datetime "user_date_7"
    t.datetime "user_date_8"
    t.datetime "user_date_9"
    t.datetime "user_date_10"
    t.string "transaction_id"
    t.integer "base_currency_code"
    t.integer "delivery_pastcode"
    t.index ["account_id"], name: "index_authorisations_on_account_id"
    t.index ["auth_date", "local_amount"], name: "index_authorisations_on_auth_date_and_local_amount"
    t.index ["card_id"], name: "index_authorisations_on_card_id"
    t.index ["client_id"], name: "index_authorisations_on_client_id"
    t.index ["id"], name: "index_authorisations_on_id"
    t.index ["jpos_auth_key"], name: "index_authorisations_on_jpos_auth_key"
    t.index ["jpos_merchant_key"], name: "index_authorisations_on_jpos_merchant_key"
    t.index ["member_id"], name: "index_authorisations_on_member_id"
    t.index ["merchant_id", "auth_date"], name: "index_authorisations_on_merchant_id_and_auth_date"
    t.index ["merchant_id"], name: "index_authorisations_on_merchant_id"
  end

  create_table "authorisations_archive", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "derived_transaction_type"
    t.string "card_name", limit: 128
    t.string "card_type", limit: 50
    t.string "card_number", limit: 128
    t.string "card_issuer", limit: 128
    t.string "card_issuer_country", limit: 50
    t.string "card_class", limit: 20
    t.datetime "expiration_date"
    t.string "auth_code", limit: 20
    t.string "cv2_check_result", limit: 20
    t.string "address_numeric_check_result", limit: 20
    t.string "post_code_check_result", limit: 20
    t.string "secure_3d_auth_check_result", limit: 20
    t.string "address"
    t.string "city", limit: 128
    t.string "post_code", limit: 50
    t.string "county", limit: 128
    t.string "country", limit: 50
    t.string "email", limit: 100
    t.string "phone_number", limit: 30
    t.string "customer_ip_address", limit: 45
    t.decimal "authorisation_amount", precision: 10
    t.decimal "{:scale=>2, :precision=>22}", precision: 10
    t.decimal "local_amount", precision: 10
    t.decimal "{:scale=>2, :precision=>22, :is_indexed=>true}", precision: 10
    t.string "auth_response", limit: 20
    t.string "auth_status", limit: 20
    t.string "transaction_type", limit: 50
    t.string "mcc", limit: 20
    t.string "ccy", limit: 10
    t.string "pos_entry_mode", limit: 1000
    t.integer "pos_condition_code"
    t.string "card_acceptor_business_code", limit: 1000
    t.integer "approval_code_length", limit: 1
    t.string "retrieval_reference_number", limit: 12
    t.string "approval_code", limit: 6
    t.string "response_code", limit: 2
    t.string "card_acceptor_terminal_id", limit: 16
    t.string "card_acceptor_id_code", limit: 15
    t.string "payee", limit: 25
    t.string "card_acceptor_name_location", limit: 1000
    t.bigint "processing_code"
    t.string "currency_code_billing", limit: 3
    t.string "additional_data_private", limit: 1000
    t.string "sys_trace_audit_number", limit: 6
    t.string "order_key"
    t.string "order_description", limit: 256
    t.string "message"
    t.string "jpos_auth_key"
    t.string "jpos_merchant_key"
    t.datetime "auth_date"
    t.datetime "transaction_datetime"
    t.bigint "card_id"
    t.bigint "account_id"
    t.bigint "member_id"
    t.bigint "merchant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "processing_host"
    t.bigint "client_id"
    t.string "jpos_client_key"
    t.string "jpos_member_key"
    t.string "user_string_1"
    t.string "user_string_2"
    t.string "user_string_3"
    t.string "user_string_4"
    t.string "user_string_5"
    t.string "user_string_6"
    t.string "user_string_7"
    t.string "user_string_8"
    t.string "user_string_9"
    t.string "user_string_10"
    t.string "user_string_11"
    t.string "user_string_12"
    t.string "user_string_13"
    t.string "user_string_14"
    t.string "user_string_15"
    t.decimal "user_number_1", precision: 22, scale: 4
    t.decimal "user_number_2", precision: 22, scale: 4
    t.decimal "user_number_3", precision: 22, scale: 4
    t.decimal "user_number_4", precision: 22, scale: 4
    t.decimal "user_number_5", precision: 22, scale: 4
    t.decimal "user_number_6", precision: 22, scale: 4
    t.decimal "user_number_7", precision: 22, scale: 4
    t.decimal "user_number_8", precision: 22, scale: 4
    t.decimal "user_number_9", precision: 22, scale: 4
    t.decimal "user_number_10", precision: 22, scale: 4
    t.datetime "user_date_1"
    t.datetime "user_date_2"
    t.datetime "user_date_3"
    t.datetime "user_date_4"
    t.datetime "user_date_5"
    t.datetime "user_date_6"
    t.datetime "user_date_7"
    t.datetime "user_date_8"
    t.datetime "user_date_9"
    t.datetime "user_date_10"
    t.datetime "user_date_11"
    t.datetime "user_date_12"
    t.datetime "user_date_13"
    t.datetime "user_date_14"
    t.datetime "user_date_15"
    t.string "transaction_id"
    t.bigint "alert_override_id"
    t.integer "base_currency_code"
    t.string "delivery_postcode", limit: 50
    t.string "product_items", limit: 999
    t.string "browser_user_agent", limit: 256
    t.string "customer_account_type", limit: 50
    t.string "delivery_method", limit: 100
    t.index ["account_id"], name: "index_authorisations_archive_on_account_id"
    t.index ["alert_override_id"], name: "index_authorisations_archive_on_alert_override_id"
    t.index ["auth_date", "local_amount"], name: "index_authorisations_archive_on_auth_date_and_local_amount"
    t.index ["card_id"], name: "index_authorisations_archive_on_card_id"
    t.index ["client_id"], name: "index_authorisations_archive_on_client_id"
    t.index ["jpos_auth_key"], name: "index_authorisations_archive_on_jpos_auth_key"
    t.index ["jpos_merchant_key"], name: "index_authorisations_archive_on_jpos_merchant_key"
    t.index ["member_id"], name: "index_authorisations_archive_on_member_id"
    t.index ["merchant_id"], name: "index_authorisations_archive_on_merchant_id"
  end

  create_table "authorisations_archive_out", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "derived_transaction_type"
    t.string "card_name", limit: 128
    t.string "card_type", limit: 50
    t.string "card_number", limit: 128
    t.string "card_issuer", limit: 128
    t.string "card_issuer_country", limit: 50
    t.string "card_class", limit: 20
    t.datetime "expiration_date"
    t.string "auth_code", limit: 20
    t.string "cv2_check_result", limit: 20
    t.string "address_numeric_check_result", limit: 20
    t.string "post_code_check_result", limit: 20
    t.string "secure_3d_auth_check_result", limit: 20
    t.string "address"
    t.string "city", limit: 128
    t.string "post_code", limit: 50
    t.string "county", limit: 128
    t.string "country", limit: 50
    t.string "email", limit: 100
    t.string "phone_number", limit: 30
    t.string "customer_ip_address", limit: 45
    t.decimal "authorisation_amount", precision: 10
    t.decimal "{:scale=>2, :precision=>22}", precision: 10
    t.decimal "local_amount", precision: 10
    t.decimal "{:scale=>2, :precision=>22, :is_indexed=>true}", precision: 10
    t.string "auth_response", limit: 20
    t.string "auth_status", limit: 20
    t.string "transaction_type", limit: 50
    t.string "mcc", limit: 20
    t.string "ccy", limit: 10
    t.string "pos_entry_mode", limit: 1000
    t.integer "pos_condition_code"
    t.string "card_acceptor_business_code", limit: 1000
    t.integer "approval_code_length", limit: 1
    t.string "retrieval_reference_number", limit: 12
    t.string "approval_code", limit: 6
    t.string "response_code", limit: 2
    t.string "card_acceptor_terminal_id", limit: 16
    t.string "card_acceptor_id_code", limit: 15
    t.string "payee", limit: 25
    t.string "card_acceptor_name_location", limit: 1000
    t.bigint "processing_code"
    t.string "currency_code_billing", limit: 3
    t.string "additional_data_private", limit: 1000
    t.string "sys_trace_audit_number", limit: 6
    t.string "order_key"
    t.string "order_description", limit: 256
    t.string "message"
    t.string "jpos_auth_key"
    t.string "jpos_merchant_key"
    t.datetime "auth_date"
    t.datetime "transaction_datetime"
    t.bigint "card_id"
    t.bigint "account_id"
    t.bigint "member_id"
    t.bigint "merchant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "processing_host"
    t.bigint "client_id"
    t.string "jpos_client_key"
    t.string "jpos_member_key"
    t.string "user_string_1"
    t.string "user_string_2"
    t.string "user_string_3"
    t.string "user_string_4"
    t.string "user_string_5"
    t.string "user_string_6"
    t.string "user_string_7"
    t.string "user_string_8"
    t.string "user_string_9"
    t.string "user_string_10"
    t.string "user_string_11"
    t.decimal "user_number_1", precision: 22, scale: 4
    t.decimal "user_number_2", precision: 22, scale: 4
    t.decimal "user_number_3", precision: 22, scale: 4
    t.decimal "user_number_4", precision: 22, scale: 4
    t.decimal "user_number_5", precision: 22, scale: 4
    t.decimal "user_number_6", precision: 22, scale: 4
    t.decimal "user_number_7", precision: 22, scale: 4
    t.decimal "user_number_8", precision: 22, scale: 4
    t.decimal "user_number_9", precision: 22, scale: 4
    t.decimal "user_number_10", precision: 22, scale: 4
    t.datetime "user_date_1"
    t.datetime "user_date_2"
    t.datetime "user_date_3"
    t.datetime "user_date_4"
    t.datetime "user_date_5"
    t.datetime "user_date_6"
    t.datetime "user_date_7"
    t.datetime "user_date_8"
    t.datetime "user_date_9"
    t.datetime "user_date_10"
    t.string "transaction_id"
    t.bigint "alert_override_id"
    t.integer "base_currency_code"
    t.string "delivery_postcode", limit: 50
    t.string "product_items", limit: 999
    t.string "browser_user_agent", limit: 256
    t.string "customer_account_type", limit: 50
    t.string "delivery_method", limit: 100
    t.index ["account_id"], name: "index_authorisations_archive_out_on_account_id"
    t.index ["alert_override_id"], name: "index_authorisations_archive_out_on_alert_override_id"
    t.index ["auth_date", "local_amount"], name: "index_authorisations_archive_out_on_auth_date_and_local_amount"
    t.index ["card_id"], name: "index_authorisations_archive_out_on_card_id"
    t.index ["client_id"], name: "index_authorisations_archive_out_on_client_id"
    t.index ["jpos_auth_key"], name: "index_authorisations_archive_out_on_jpos_auth_key"
    t.index ["jpos_merchant_key"], name: "index_authorisations_archive_out_on_jpos_merchant_key"
    t.index ["member_id"], name: "index_authorisations_archive_out_on_member_id"
    t.index ["merchant_id"], name: "index_authorisations_archive_out_on_merchant_id"
  end

  create_table "authorisations_out", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "derived_transaction_type"
    t.string "card_name", limit: 128
    t.string "card_type", limit: 50
    t.string "card_number", limit: 128
    t.string "card_issuer", limit: 128
    t.string "card_issuer_country", limit: 50
    t.string "card_class", limit: 20
    t.datetime "expiration_date"
    t.string "auth_code", limit: 20
    t.string "cv2_check_result", limit: 20
    t.string "address_numeric_check_result", limit: 20
    t.string "post_code_check_result", limit: 20
    t.string "secure_3d_auth_check_result", limit: 20
    t.string "address"
    t.string "city", limit: 128
    t.string "post_code", limit: 50
    t.string "county", limit: 128
    t.string "country", limit: 50
    t.string "email", limit: 100
    t.string "phone_number", limit: 30
    t.string "customer_ip_address", limit: 45
    t.decimal "authorisation_amount", precision: 10
    t.decimal "{:scale=>2, :precision=>22}", precision: 10
    t.decimal "local_amount", precision: 10
    t.decimal "{:scale=>2, :precision=>22, :is_indexed=>true}", precision: 10
    t.string "auth_response", limit: 20
    t.string "auth_status", limit: 20
    t.string "transaction_type", limit: 50
    t.string "mcc", limit: 20
    t.string "ccy", limit: 10
    t.string "pos_entry_mode", limit: 1000
    t.integer "pos_condition_code"
    t.string "card_acceptor_business_code", limit: 1000
    t.integer "approval_code_length", limit: 1
    t.string "retrieval_reference_number", limit: 12
    t.string "approval_code", limit: 6
    t.string "response_code", limit: 2
    t.string "card_acceptor_terminal_id", limit: 16
    t.string "card_acceptor_id_code", limit: 15
    t.string "payee", limit: 25
    t.string "card_acceptor_name_location", limit: 1000
    t.bigint "processing_code"
    t.string "currency_code_billing", limit: 3
    t.string "additional_data_private", limit: 1000
    t.string "sys_trace_audit_number", limit: 6
    t.string "order_key"
    t.string "order_description", limit: 256
    t.string "message"
    t.string "jpos_auth_key"
    t.string "jpos_merchant_key"
    t.datetime "auth_date"
    t.datetime "transaction_datetime"
    t.bigint "card_id"
    t.bigint "account_id"
    t.bigint "member_id"
    t.bigint "merchant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "processing_host"
    t.bigint "client_id"
    t.string "jpos_client_key"
    t.string "jpos_member_key"
    t.string "user_string_1"
    t.string "user_string_2"
    t.string "user_string_3"
    t.string "user_string_4"
    t.string "user_string_5"
    t.string "user_string_6"
    t.string "user_string_7"
    t.string "user_string_8"
    t.string "user_string_9"
    t.string "user_string_10"
    t.decimal "user_number_1", precision: 22, scale: 4
    t.decimal "user_number_2", precision: 22, scale: 4
    t.decimal "user_number_3", precision: 22, scale: 4
    t.decimal "user_number_4", precision: 22, scale: 4
    t.decimal "user_number_5", precision: 22, scale: 4
    t.decimal "user_number_6", precision: 22, scale: 4
    t.decimal "user_number_7", precision: 22, scale: 4
    t.decimal "user_number_8", precision: 22, scale: 4
    t.decimal "user_number_9", precision: 22, scale: 4
    t.decimal "user_number_10", precision: 22, scale: 4
    t.decimal "user_number_11", precision: 22, scale: 4
    t.datetime "user_date_1"
    t.datetime "user_date_2"
    t.datetime "user_date_3"
    t.datetime "user_date_4"
    t.datetime "user_date_5"
    t.datetime "user_date_6"
    t.datetime "user_date_7"
    t.datetime "user_date_8"
    t.datetime "user_date_9"
    t.datetime "user_date_10"
    t.string "transaction_id"
    t.integer "base_currency_code"
    t.string "delivery_postcode", limit: 50
    t.string "product_items", limit: 999
    t.string "browser_user_agent", limit: 256
    t.string "customer_account_type", limit: 50
    t.string "delivery_method", limit: 100
    t.index ["account_id"], name: "index_authorisations_out_on_account_id"
    t.index ["auth_date", "local_amount"], name: "index_authorisations_out_on_auth_date_and_local_amount"
    t.index ["card_id"], name: "index_authorisations_out_on_card_id"
    t.index ["client_id", "auth_date"], name: "index_authorisations_out_on_client_id_and_auth_date"
    t.index ["client_id"], name: "index_authorisations_out_on_client_id"
    t.index ["id"], name: "index_authorisations_out_on_id"
    t.index ["jpos_auth_key"], name: "index_authorisations_out_on_jpos_auth_key"
    t.index ["jpos_merchant_key"], name: "index_authorisations_out_on_jpos_merchant_key"
    t.index ["member_id", "auth_date"], name: "index_authorisations_out_on_member_id_and_auth_date"
    t.index ["member_id"], name: "index_authorisations_out_on_member_id"
    t.index ["merchant_id", "auth_date"], name: "index_authorisations_out_on_merchant_id_and_auth_date"
  end

  create_table "cards", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name_on_card"
    t.string "card_number"
    t.string "last_four"
    t.string "card_type"
    t.string "card_class"
    t.datetime "expiration_date"
    t.datetime "valid_year"
    t.datetime "valid_month"
    t.string "status"
    t.string "issuer"
    t.string "issuer_country"
    t.string "bin"
    t.bigint "customer_id"
    t.bigint "member_id"
    t.bigint "merchant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "client_id", null: false
    t.index ["client_id"], name: "index_cards_on_client_id"
    t.index ["customer_id"], name: "index_cards_on_customer_id"
    t.index ["member_id"], name: "index_cards_on_member_id"
    t.index ["merchant_id"], name: "index_cards_on_merchant_id"
  end

  create_table "clients", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "internal_code"
    t.string "jpos_key"
    t.bigint "member_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "address1"
    t.string "address2"
    t.string "post_code", limit: 20
    t.string "telephone"
    t.string "country", limit: 128
    t.string "address"
    t.string "mcc", limit: 4
    t.string "contact", limit: 100
    t.string "phone", limit: 30
    t.string "fax"
    t.string "email", limit: 100
    t.string "company_id", limit: 20
    t.string "vat_number", limit: 20
    t.string "company_reg", limit: 4
    t.string "owing_bank"
    t.string "bank_acc_no", limit: 20
    t.string "bank_sort_code", limit: 10
    t.string "sales_exec_code"
    t.boolean "cnp_type"
    t.datetime "open_date"
    t.datetime "closed_date"
    t.integer "floor_limit"
    t.integer "data_collection"
    t.integer "control_id"
    t.string "control_area"
    t.string "currency_code"
    t.string "state", limit: 4
    t.string "business_segment"
    t.string "business_type"
    t.string "county", limit: 128
    t.string "web_address"
    t.integer "mrm_category"
    t.boolean "billing_point"
    t.boolean "settlement_point"
    t.boolean "parent_flag"
    t.string "group_no", limit: 4
    t.string "trade_assoc"
    t.string "settle_method"
    t.integer "sett_sort_code"
    t.integer "sett_account"
    t.string "clearing_name"
    t.string "clearing_city"
    t.string "contactless"
    t.string "defer_sett_amt", limit: 4
    t.integer "cur_bal_amt"
    t.string "business_cat"
    t.string "type_of_goods_sold", limit: 4
    t.integer "comm_card_no"
    t.integer "comm_card_limit"
    t.string "ret_reward_prog"
    t.index ["member_id"], name: "index_clients_on_member_id"
  end

  create_table "comments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "title", limit: 50, default: ""
    t.string "comment_text"
    t.string "role", default: "comments"
    t.string "entered_by"
    t.string "last_updated_by"
    t.bigint "commentable_id"
    t.string "commentable_type"
    t.bigint "alert_id"
    t.bigint "user_id"
    t.datetime "alert_created_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_id"], name: "index_comments_on_alert_id"
    t.index ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type"
    t.index ["commentable_id"], name: "index_comments_on_commentable_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "comments_archive", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "title", limit: 50, default: ""
    t.string "comment_text"
    t.string "role", default: "comments"
    t.string "entered_by"
    t.string "last_updated_by"
    t.bigint "commentable_id"
    t.string "commentable_type"
    t.bigint "alert_id"
    t.bigint "user_id"
    t.datetime "alert_created_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_id"], name: "index_comments_archive_on_alert_id"
    t.index ["commentable_id"], name: "index_comments_archive_on_commentable_id"
    t.index ["user_id"], name: "index_comments_archive_on_user_id"
  end

  create_table "comments_archive_out", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "title", limit: 50, default: ""
    t.string "comment_text"
    t.string "role", default: "comments"
    t.string "entered_by"
    t.string "last_updated_by"
    t.bigint "commentable_id"
    t.string "commentable_type"
    t.bigint "alert_id"
    t.bigint "user_id"
    t.datetime "alert_created_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_id"], name: "index_comments_archive_out_on_alert_id"
    t.index ["commentable_id"], name: "index_comments_archive_out_on_commentable_id"
    t.index ["user_id"], name: "index_comments_archive_out_on_user_id"
  end

  create_table "comments_out", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "title", limit: 50, default: ""
    t.string "comment_text"
    t.string "role", default: "comments"
    t.string "entered_by"
    t.string "last_updated_by"
    t.bigint "commentable_id"
    t.string "commentable_type"
    t.bigint "alert_id"
    t.bigint "user_id"
    t.datetime "alert_created_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_id"], name: "index_comments_out_on_alert_id"
    t.index ["commentable_id", "commentable_type"], name: "index_comments_out_on_commentable_id_and_commentable_type"
    t.index ["commentable_id"], name: "index_comments_out_on_commentable_id"
    t.index ["user_id"], name: "index_comments_out_on_user_id"
  end

  create_table "criteria", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "detail_type"
    t.string "detail"
    t.string "constraint"
    t.string "value"
    t.string "right_operator"
    t.integer "right_operator_value"
    t.boolean "include_empty", default: false
    t.boolean "affects_priority", default: false
    t.string "description"
    t.bigint "rule_id"
    t.bigint "statistic_id"
    t.string "leftable_type"
    t.bigint "leftable_id"
    t.string "rightable_type"
    t.bigint "rightable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["leftable_id", "leftable_type"], name: "index_criteria_on_leftable_id_and_leftable_type"
    t.index ["leftable_type", "leftable_id"], name: "index_criteria_on_leftable"
    t.index ["rightable_id", "rightable_type"], name: "index_criteria_on_rightable_id_and_rightable_type"
    t.index ["rightable_type", "rightable_id"], name: "index_criteria_on_rightable"
    t.index ["rule_id"], name: "index_criteria_on_rule_id"
    t.index ["statistic_id"], name: "index_criteria_on_statistic_id"
  end

  create_table "criteria_cards", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "value"
    t.string "data_type", default: "string"
    t.string "masked_value"
    t.string "bin"
    t.string "last4"
    t.integer "card_length"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "criteria_parameters", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "value"
    t.string "data_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "criteria_summaries", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "data_type"
    t.bigint "data_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data_id", "data_type"], name: "index_criteria_summaries_on_data_id_and_data_type", unique: true
    t.index ["data_id"], name: "index_criteria_summaries_on_data_id"
    t.index ["data_type", "data_id"], name: "index_criteria_summaries_on_data"
  end

  create_table "currency_pairs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "transaction_currency_code", null: false
    t.integer "base_currency_code", null: false
    t.float "conversion_rate", null: false
    t.string "currency_pair_ownerable_type"
    t.bigint "currency_pair_ownerable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency_pair_ownerable_type", "currency_pair_ownerable_id"], name: "index_currency_pairs_on_currency_pair_ownerable"
    t.index ["transaction_currency_code", "base_currency_code", "currency_pair_ownerable_id", "currency_pair_ownerable_type"], name: "currency_pair_uniqueness_index", unique: true
  end

  create_table "customers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "full_name"
    t.string "address1"
    t.string "address2"
    t.string "post_code"
    t.string "telephone"
    t.string "country"
    t.bigint "member_id"
    t.bigint "merchant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["full_name", "merchant_id"], name: "index_customers_on_name_and_merchant"
    t.index ["member_id"], name: "index_customers_on_member_id"
    t.index ["merchant_id"], name: "index_customers_on_merchant_id"
  end

  create_table "data_lists", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "data_type"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "deleted", default: false
    t.bigint "user_id"
    t.boolean "read_only"
    t.bigint "owner_id"
    t.string "owner_type"
    t.index ["owner_id"], name: "index_data_lists_on_owner_id"
    t.index ["user_id"], name: "index_data_lists_on_user_id"
  end

  create_table "database_connections", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "server_name"
    t.string "database_name"
    t.boolean "batch"
    t.boolean "report"
    t.boolean "realtime"
    t.boolean "online"
    t.string "publication_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "enrichment_results", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "authorisation_id"
    t.datetime "authorisation_created_at"
    t.string "owner_type"
    t.bigint "owner_id"
    t.decimal "enrichment_result_1", precision: 10
    t.decimal "{:scale=>4, :precision=>22}", precision: 10
    t.decimal "enrichment_result_2", precision: 10
    t.decimal "enrichment_result_3", precision: 10
    t.decimal "enrichment_result_4", precision: 10
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["authorisation_id"], name: "index_enrichment_results_on_authorisation_id"
    t.index ["owner_type", "owner_id", "authorisation_created_at", "authorisation_id"], name: "index_enrichment_results_clustered", unique: true
    t.index ["owner_type", "owner_id"], name: "index_enrichment_results_on_owner"
  end

  create_table "enrichment_results_archive", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "authorisation_id"
    t.datetime "authorisation_created_at"
    t.string "owner_type"
    t.bigint "owner_id"
    t.decimal "enrichment_result_1", precision: 10
    t.decimal "{:scale=>4, :precision=>22}", precision: 10
    t.decimal "enrichment_result_2", precision: 10
    t.decimal "enrichment_result_3", precision: 10
    t.decimal "enrichment_result_4", precision: 10
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["authorisation_id"], name: "index_enrichment_results_archive_on_authorisation_id"
    t.index ["owner_type", "owner_id", "authorisation_created_at", "authorisation_id"], name: "index_enrichment_results_archive_c", unique: true
    t.index ["owner_type", "owner_id"], name: "index_enrichment_results_archive_on_owner"
  end

  create_table "enrichment_results_archive_out", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "authorisation_id"
    t.datetime "authorisation_created_at"
    t.string "owner_type"
    t.bigint "owner_id"
    t.decimal "enrichment_result_1", precision: 10
    t.decimal "{:scale=>4, :precision=>22}", precision: 10
    t.decimal "enrichment_result_2", precision: 10
    t.decimal "enrichment_result_3", precision: 10
    t.decimal "enrichment_result_4", precision: 10
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["authorisation_id"], name: "index_enrichment_results_archive_out_on_authorisation_id"
    t.index ["owner_type", "owner_id", "authorisation_created_at", "authorisation_id"], name: "index_enrichment_results_archive_out_c", unique: true
    t.index ["owner_type", "owner_id"], name: "index_enrichment_results_archive_out_on_owner"
  end

  create_table "enrichment_results_out", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "authorisation_id"
    t.datetime "authorisation_created_at"
    t.string "owner_type"
    t.bigint "owner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["authorisation_id"], name: "index_enrichment_results_out_on_authorisation_id"
    t.index ["owner_type", "owner_id", "authorisation_created_at", "authorisation_id"], name: "index_enrichment_results_out_c", unique: true
    t.index ["owner_type", "owner_id"], name: "index_enrichment_results_out_on_owner"
  end

  create_table "enrichments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "query_pattern", limit: 4000
    t.string "order_clause"
    t.boolean "contains_where", default: true
    t.string "placeholder_1"
    t.string "placeholder_2"
    t.string "placeholder_3"
    t.string "placeholder_4"
    t.string "owner_type"
    t.bigint "owner_id"
    t.bigint "field_list_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["field_list_id"], name: "index_enrichments_on_field_list_id"
    t.index ["owner_type", "owner_id", "field_list_id"], name: "index_enrichments_unique_1", unique: true
    t.index ["owner_type", "owner_id"], name: "index_enrichments_on_owner"
  end

  create_table "field_list_mapping_owners", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "field_list_id"
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "name"
    t.boolean "sensitive", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["field_list_id"], name: "index_field_list_mapping_owners_on_field_list_id"
    t.index ["owner_type", "owner_id"], name: "index_field_list_mapping_owners_on_owner"
  end

  create_table "field_lists", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "data_type"
    t.string "model_type"
    t.boolean "visible", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ext_provider_field_name"
    t.boolean "is_ext_provider_field"
    t.index ["model_type", "name"], name: "index_field_lists_on_model_type_and_name", unique: true
    t.index ["model_type"], name: "index_field_lists_on_model_type"
  end

  create_table "frauds", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "authorisation_created_at"
    t.bigint "authorisation_id"
    t.integer "fraud_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["authorisation_created_at", "authorisation_id"], name: "index_frauds_on_authorisation"
  end

  create_table "frauds_archive", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "authorisation_created_at"
    t.bigint "authorisation_id"
    t.integer "fraud_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["authorisation_id"], name: "index_frauds_archive_on_authorisation_id"
  end

  create_table "frauds_archive_out", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "authorisation_created_at"
    t.bigint "authorisation_id"
    t.integer "fraud_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["authorisation_id"], name: "index_frauds_archive_out_on_authorisation_id"
  end

  create_table "frauds_out", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "authorisation_created_at"
    t.bigint "authorisation_id"
    t.integer "fraud_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["authorisation_created_at", "authorisation_id"], name: "index_frauds_out_on_authorisation"
  end

  create_table "installations", id: :bigint, default: nil, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "database_version"
  end

  create_table "investigations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "state"
    t.string "pan"
    t.datetime "transaction_date"
    t.decimal "transaction_amount", precision: 22, scale: 2
    t.string "amount_local_ccy"
    t.boolean "normal_spending"
    t.boolean "cardholder_contacted"
    t.boolean "cardholder_possession"
    t.boolean "goods_received"
    t.boolean "chased"
    t.boolean "declaration_ordered"
    t.boolean "voucher_present"
    t.boolean "deleted"
    t.string "investigation_type"
    t.string "due_to"
    t.datetime "alert_created_at", null: false
    t.datetime "authorisation_created_at", null: false
    t.bigint "user_id"
    t.bigint "authorisation_id"
    t.bigint "merchant_id"
    t.bigint "alert_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_id"], name: "index_investigations_on_alert_id"
    t.index ["authorisation_id"], name: "index_investigations_on_authorisation_id"
    t.index ["merchant_id"], name: "index_investigations_on_merchant_id"
    t.index ["user_id"], name: "index_investigations_on_user_id"
  end

  create_table "investigations_archive", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "state"
    t.string "pan"
    t.datetime "transaction_date"
    t.decimal "transaction_amount", precision: 22, scale: 2
    t.string "amount_local_ccy"
    t.boolean "normal_spending"
    t.boolean "cardholder_contacted"
    t.boolean "cardholder_possession"
    t.boolean "goods_received"
    t.boolean "chased"
    t.boolean "declaration_ordered"
    t.boolean "voucher_present"
    t.boolean "deleted"
    t.string "investigation_type"
    t.string "due_to"
    t.datetime "alert_created_at", null: false
    t.datetime "authorisation_created_at", null: false
    t.bigint "user_id"
    t.bigint "authorisation_id"
    t.bigint "merchant_id"
    t.bigint "alert_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_id"], name: "index_investigations_archive_on_alert_id"
    t.index ["authorisation_id"], name: "index_investigations_archive_on_authorisation_id"
    t.index ["merchant_id"], name: "index_investigations_archive_on_merchant_id"
    t.index ["user_id"], name: "index_investigations_archive_on_user_id"
  end

  create_table "investigations_archive_out", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "state"
    t.string "pan"
    t.datetime "transaction_date"
    t.decimal "transaction_amount", precision: 22, scale: 2
    t.string "amount_local_ccy"
    t.boolean "normal_spending"
    t.boolean "cardholder_contacted"
    t.boolean "cardholder_possession"
    t.boolean "goods_received"
    t.boolean "chased"
    t.boolean "declaration_ordered"
    t.boolean "voucher_present"
    t.boolean "deleted"
    t.string "investigation_type"
    t.string "due_to"
    t.datetime "alert_created_at", null: false
    t.datetime "authorisation_created_at", null: false
    t.bigint "user_id"
    t.bigint "authorisation_id"
    t.bigint "merchant_id"
    t.bigint "alert_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_id"], name: "index_investigations_archive_out_on_alert_id"
    t.index ["authorisation_id"], name: "index_investigations_archive_out_on_authorisation_id"
    t.index ["merchant_id"], name: "index_investigations_archive_out_on_merchant_id"
    t.index ["user_id"], name: "index_investigations_archive_out_on_user_id"
  end

  create_table "investigations_out", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "state"
    t.string "pan"
    t.datetime "transaction_date"
    t.decimal "transaction_amount", precision: 22, scale: 2
    t.string "amount_local_ccy"
    t.boolean "normal_spending"
    t.boolean "cardholder_contacted"
    t.boolean "cardholder_possession"
    t.boolean "goods_received"
    t.boolean "chased"
    t.boolean "declaration_ordered"
    t.boolean "voucher_present"
    t.boolean "deleted"
    t.string "investigation_type"
    t.string "due_to"
    t.datetime "alert_created_at", null: false
    t.datetime "authorisation_created_at", null: false
    t.bigint "user_id"
    t.bigint "authorisation_id"
    t.bigint "merchant_id"
    t.bigint "alert_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_id"], name: "index_investigations_out_on_alert_id"
    t.index ["authorisation_id"], name: "index_investigations_out_on_authorisation_id"
    t.index ["merchant_id"], name: "index_investigations_out_on_merchant_id"
    t.index ["user_id"], name: "index_investigations_out_on_user_id"
  end

  create_table "join_statistics_timeframes", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "statistic_id"
    t.bigint "statistic_timeframe_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["statistic_id", "statistic_timeframe_id"], name: "index_join_statistics_timeframes_sid_stfid"
    t.index ["statistic_id"], name: "index_join_statistics_timeframes_on_statistic_id"
    t.index ["statistic_timeframe_id"], name: "index_join_statistics_timeframes_on_statistic_timeframe_id"
  end

  create_table "journals", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "event_type"
    t.string "info_1"
    t.string "info_2"
    t.string "info_3"
    t.string "info_4"
    t.datetime "event_date"
    t.datetime "alert_created_at"
    t.string "category"
    t.bigint "alert_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_id"], name: "index_journals_on_alert_id"
    t.index ["user_id"], name: "index_journals_on_user_id"
  end

  create_table "journals_archive", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "event_type"
    t.string "info_1"
    t.string "info_2"
    t.string "info_3"
    t.string "info_4"
    t.datetime "event_date"
    t.datetime "alert_created_at"
    t.string "category"
    t.bigint "alert_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_id"], name: "index_journals_archive_on_alert_id"
    t.index ["user_id"], name: "index_journals_archive_on_user_id"
  end

  create_table "journals_archive_out", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "event_type"
    t.string "info_1"
    t.string "info_2"
    t.string "info_3"
    t.string "info_4"
    t.datetime "event_date"
    t.datetime "alert_created_at"
    t.string "category"
    t.bigint "alert_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_id"], name: "index_journals_archive_out_on_alert_id"
    t.index ["user_id"], name: "index_journals_archive_out_on_user_id"
  end

  create_table "journals_out", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "event_type"
    t.string "info_1"
    t.string "info_2"
    t.string "info_3"
    t.string "info_4"
    t.datetime "event_date"
    t.datetime "alert_created_at"
    t.string "category"
    t.bigint "alert_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_id"], name: "index_journals_out_on_alert_id"
    t.index ["user_id"], name: "index_journals_out_on_user_id"
  end

  create_table "link_field_data_lists", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "field_list_id"
    t.bigint "data_list_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data_list_id"], name: "index_link_field_data_lists_on_data_list_id"
    t.index ["field_list_id", "data_list_id"], name: "index_link_field_data_lists_on_field_list_id_and_data_list_id"
    t.index ["field_list_id"], name: "index_link_field_data_lists_on_field_list_id"
  end

  create_table "list_items", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "frontend_name"
    t.string "value"
    t.string "description"
    t.string "list_type"
    t.bigint "data_list_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "visible", default: false
    t.index ["data_list_id"], name: "index_list_items_on_data_list"
    t.index ["data_list_id"], name: "index_list_items_on_data_list_id"
  end

  create_table "members", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "department_name"
    t.string "address1"
    t.string "address2"
    t.string "post_code"
    t.string "telephone"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jpos_key"
    t.string "internal_code", limit: 100
    t.string "address"
    t.string "mcc", limit: 4
    t.string "contact", limit: 100
    t.string "phone", limit: 30
    t.string "fax"
    t.string "email", limit: 100
    t.string "company_id", limit: 20
    t.string "vat_number", limit: 20
    t.string "company_reg", limit: 4
    t.string "owing_bank"
    t.string "bank_acc_no", limit: 20
    t.string "bank_sort_code", limit: 10
    t.string "sales_exec_code"
    t.boolean "cnp_type"
    t.datetime "open_date"
    t.datetime "closed_date"
    t.integer "floor_limit"
    t.integer "data_collection"
    t.integer "control_id"
    t.string "control_area"
    t.string "currency_code"
    t.string "state", limit: 4
    t.string "business_segment"
    t.string "business_type"
    t.string "county", limit: 128
    t.string "web_address"
    t.integer "mrm_category"
    t.boolean "billing_point"
    t.boolean "settlement_point"
    t.boolean "parent_flag"
    t.string "group_no", limit: 4
    t.string "trade_assoc"
    t.string "settle_method"
    t.integer "sett_sort_code"
    t.integer "sett_account"
    t.string "clearing_name"
    t.string "clearing_city"
    t.string "contactless"
    t.string "defer_sett_amt", limit: 4
    t.integer "cur_bal_amt"
    t.string "business_cat"
    t.string "type_of_goods_sold", limit: 4
    t.integer "comm_card_no"
    t.integer "comm_card_limit"
    t.string "ret_reward_prog"
  end

  create_table "merchants", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", limit: 100
    t.string "internal_code", limit: 100
    t.string "address1"
    t.string "address2"
    t.string "post_code", limit: 30
    t.string "telephone"
    t.string "country", limit: 128
    t.string "address"
    t.string "mcc", limit: 4
    t.string "contact", limit: 100
    t.string "phone", limit: 40
    t.string "fax"
    t.string "email", limit: 100
    t.string "company_id", limit: 20
    t.string "vat_number", limit: 40
    t.string "company_reg", limit: 4
    t.string "owning_bank"
    t.string "bank_acc_no", limit: 20
    t.string "bank_sort_code", limit: 10
    t.string "sales_exec_code"
    t.boolean "cnp_type"
    t.datetime "open_date"
    t.datetime "closed_date"
    t.integer "floor_limit"
    t.integer "data_collection"
    t.bigint "control_id"
    t.string "control_area"
    t.string "currency_code"
    t.string "state", limit: 4
    t.string "business_segment"
    t.string "business_type"
    t.string "county", limit: 128
    t.string "web_address"
    t.integer "mrm_category"
    t.boolean "billing_point"
    t.boolean "settlement_point"
    t.boolean "parent_flag"
    t.string "group_no", limit: 4
    t.string "trade_assoc"
    t.string "settle_method"
    t.integer "sett_sort_code"
    t.integer "sett_account"
    t.string "clearing_name"
    t.string "clearing_city"
    t.string "contactless"
    t.integer "defer_sett_amt"
    t.integer "cur_bal_amt"
    t.string "business_cat"
    t.string "type_of_goods_sold"
    t.integer "comm_card_no"
    t.integer "comm_card_limit"
    t.string "ret_reward_prog"
    t.string "jpos_key", limit: 20
    t.bigint "member_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "client_id"
    t.index ["client_id"], name: "index_merchants_on_client_id"
    t.index ["jpos_key"], name: "index_merchants_on_jpos_key"
    t.index ["member_id"], name: "index_merchants_on_member_id"
  end

  create_table "miscellaneous_infos", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key"
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "old_passwords", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "encrypted_password", null: false
    t.string "password_salt"
    t.string "password_archivable_type", null: false
    t.bigint "password_archivable_id", null: false
    t.datetime "created_at"
    t.index ["password_archivable_type", "password_archivable_id"], name: "index_password_archivable"
  end

  create_table "override_cards", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "card_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "bin"
    t.string "last_four"
    t.string "masked_card_number"
  end

  create_table "override_types", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reminders", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "reason"
    t.datetime "reminder_time"
    t.datetime "alert_created_at", null: false
    t.boolean "expired", default: false
    t.boolean "cleared", default: false
    t.datetime "cleared_on"
    t.string "job_id"
    t.string "job_type"
    t.bigint "alert_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_id"], name: "index_reminders_on_alert_id"
  end

  create_table "reminders_archive", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "reason"
    t.datetime "reminder_time"
    t.datetime "alert_created_at", null: false
    t.boolean "expired", default: false
    t.boolean "cleared", default: false
    t.datetime "cleared_on"
    t.string "job_id"
    t.string "job_type"
    t.bigint "alert_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_id"], name: "index_reminders_archive_on_alert_id"
  end

  create_table "reminders_archive_out", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "reason"
    t.datetime "reminder_time"
    t.datetime "alert_created_at", null: false
    t.boolean "expired", default: false
    t.boolean "cleared", default: false
    t.datetime "cleared_on"
    t.string "job_id"
    t.string "job_type"
    t.bigint "alert_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_id"], name: "index_reminders_archive_out_on_alert_id"
  end

  create_table "reminders_out", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "reason"
    t.datetime "reminder_time"
    t.datetime "alert_created_at", null: false
    t.boolean "expired", default: false
    t.boolean "cleared", default: false
    t.datetime "cleared_on"
    t.string "job_id"
    t.string "job_type"
    t.bigint "alert_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alert_id"], name: "index_reminders_out_on_alert_id"
  end

  create_table "report_results", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "result"
    t.string "timestamps"
    t.boolean "finished"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "executed_by"
    t.boolean "deleted"
    t.bigint "executed_by_id"
    t.bigint "report_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["executed_by_id"], name: "index_report_results_on_executed_by_id"
    t.index ["report_id"], name: "index_report_results_on_report_id"
  end

  create_table "reports", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "report_type"
    t.string "date_range", null: false
    t.string "report_grouping", limit: 4000
    t.string "report_definition", limit: 4000
    t.string "created_by"
    t.datetime "last_execution"
    t.boolean "deleted"
    t.bigint "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title", null: false
    t.integer "target_id"
    t.string "target_type"
    t.index ["created_by_id"], name: "index_reports_on_created_by_id"
  end

  create_table "roles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "rule_schedule_week_days", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "rule_schedule_id"
    t.bigint "week_day_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rule_schedule_id"], name: "index_rule_schedule_week_days_on_rule_schedule_id"
    t.index ["week_day_id"], name: "index_rule_schedule_week_days_on_week_day_id"
  end

  create_table "rule_schedules", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "rule_id"
    t.datetime "start_datetime"
    t.datetime "end_datetime"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rule_id"], name: "index_rule_schedules_on_rule_id"
  end

  create_table "rules", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "member"
    t.string "level"
    t.string "rule_type"
    t.string "internal_code", limit: 100
    t.text "description"
    t.string "priority_calculation"
    t.string "priority_totalling"
    t.string "rule_evaluation_type"
    t.string "evaluation_type"
    t.integer "priority"
    t.boolean "enhanced_priority_calculation"
    t.string "outcome"
    t.integer "violation_limit", default: 500
    t.boolean "active", default: true
    t.boolean "simulation", default: false
    t.boolean "deleted", default: false
    t.string "owner_type"
    t.bigint "owner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "parent_id"
    t.bigint "category_id"
    t.boolean "visible", default: false
    t.boolean "add_to_list", default: false
    t.integer "time_value"
    t.string "time_period"
    t.string "override_type"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.index ["category_id"], name: "index_rules_on_category_id"
    t.index ["internal_code"], name: "index_rules_on_internal_code", unique: true
    t.index ["owner_id"], name: "index_rules_on_owner_id"
    t.index ["owner_type", "owner_id"], name: "index_rules_on_owner"
    t.index ["parent_id"], name: "index_rules_on_parent_id"
  end

  create_table "server_epochs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "server_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["server_id"], name: "index_server_epochs_on_server_id"
  end

  create_table "sites", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "site_code", null: false
    t.decimal "latitude", precision: 10
    t.decimal "longitude", precision: 10
    t.string "owner_type"
    t.bigint "owner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id"], name: "index_sites_on_owner"
  end

  create_table "statistic", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "stat_code", limit: 100
    t.string "stat_type"
    t.string "created_by"
    t.string "updated_by"
    t.boolean "deleted"
    t.boolean "mandatory"
    t.integer "calculation_order"
    t.string "category"
    t.string "description"
    t.boolean "average", default: false
    t.boolean "is_distinct", default: false
    t.boolean "grouped", default: false
    t.bigint "statistics_operation_id"
    t.bigint "user_id"
    t.bigint "field_list_id"
    t.bigint "grouping_factor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["field_list_id"], name: "index_statistic_on_field_list_id"
    t.index ["grouping_factor_id"], name: "index_statistic_on_grouping_factor_id"
    t.index ["stat_code"], name: "index_statistic_on_stat_code", unique: true
    t.index ["statistics_operation_id"], name: "index_statistic_on_statistics_operation_id"
    t.index ["user_id"], name: "index_statistic_on_user_id"
  end

  create_table "statistic_calculations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "calc_type"
    t.integer "from_period"
    t.integer "to_period"
    t.string "description"
    t.string "grouping_operator"
    t.boolean "calculate_on_the_fly", default: false
    t.boolean "date_only", default: false
    t.bigint "statistic_id"
    t.bigint "statistic_timeframe_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "statistic_index_id"
    t.boolean "ignore_first_in_window", default: false
    t.bigint "statistic_table_id"
    t.index ["statistic_id"], name: "index_statistic_calculations_on_statistic_id"
    t.index ["statistic_index_id"], name: "index_statistic_calculations_on_statistic_index_id"
    t.index ["statistic_table_id"], name: "index_statistic_calculations_on_statistic_table_id"
    t.index ["statistic_timeframe_id"], name: "index_statistic_calculations_on_statistic_timeframe_id"
  end

  create_table "statistic_group_results", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", null: false
    t.float "value", null: false
    t.bigint "statistic_id"
    t.datetime "from_date"
    t.datetime "to_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["statistic_id"], name: "index_statistic_group_results_on_statistic_id"
  end

  create_table "statistic_group_results_out", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", null: false
    t.float "value", null: false
    t.bigint "statistic_id"
    t.datetime "from_date"
    t.datetime "to_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["statistic_id"], name: "index_statistic_group_results_out_on_statistic_id"
  end

  create_table "statistic_indices", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "column_ddl"
    t.string "where_ddl"
    t.string "date_ddl"
    t.bigint "statistic_timeframe_id"
    t.integer "from_period"
    t.boolean "deleted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "containing_statistic_index_id"
    t.index ["statistic_timeframe_id"], name: "index_statistic_indices_on_statistic_timeframe_id"
  end

  create_table "statistic_results", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.float "value"
    t.bigint "statistic_calculation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["statistic_calculation_id"], name: "index_statistic_results_on_statistic_calculation_id"
  end

  create_table "statistic_tables", id: :bigint, default: nil, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "table_ddl"
    t.string "index_ddl"
    t.string "sql_column_list"
    t.string "where_dml"
    t.integer "from_period"
    t.integer "from_period_seconds"
    t.bigint "containing_statistic_table"
    t.bigint "populated_containing_statistic_table"
    t.integer "deleted", limit: 1
    t.integer "populated", limit: 1
    t.integer "table_created", limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "rules_active"
    t.bigint "owner_id"
  end

  create_table "statistic_timeframes", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "timeframe_type"
    t.string "aggregate_level"
    t.string "turnover"
    t.integer "aggregate_length"
    t.bigint "statistic_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["statistic_id"], name: "index_statistic_timeframes_on_statistic_id"
  end

  create_table "statistics_operations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "op_type"
    t.string "op_code"
    t.string "operator"
    t.string "op_datatype"
    t.integer "size"
    t.string "calc_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "suspect_lists", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "suspect_type"
    t.string "pan"
    t.datetime "expires_on"
    t.boolean "deleted"
    t.string "suspectable_type"
    t.bigint "suspectable_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["suspect_type"], name: "index_suspect_lists_on_suspect_type"
    t.index ["suspectable_id", "suspectable_type"], name: "index_suspect_lists_on_suspectable_id_and_suspectable_type"
    t.index ["suspectable_type", "suspectable_id"], name: "index_suspect_lists_on_suspectable"
    t.index ["user_id"], name: "index_suspect_lists_on_user_id"
  end

  create_table "table_epochs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "object_id", null: false
    t.string "object_type", null: false
    t.bigint "server_epoch_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["server_epoch_id"], name: "index_table_epochs_on_server_epoch_id"
  end

  create_table "table_epochs_out", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "object_id", null: false
    t.string "object_type", null: false
    t.bigint "server_epoch_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["server_epoch_id"], name: "index_table_epochs_out_on_server_epoch_id"
  end

  create_table "translations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "locale"
    t.string "key"
    t.string "value"
    t.string "interpolations"
    t.boolean "is_proc", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "used_statistic_indices", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.bigint "statistic_index_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["statistic_index_id"], name: "index_used_statistic_indices_on_statistic_index_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  create_table "versions", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "item_type", limit: 191, null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object", size: :long
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "violations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "internal_code"
    t.integer "rule_priority"
    t.datetime "alert_created_at", null: false
    t.datetime "authorisation_created_at", null: false
    t.bigint "alert_id"
    t.bigint "rule_id"
    t.bigint "account_id"
    t.bigint "authorisation_id"
    t.bigint "customer_id"
    t.string "violatable_type"
    t.bigint "violatable_id"
    t.bigint "merchant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_violations_on_account_id"
    t.index ["alert_id"], name: "index_violations_on_alert_id"
    t.index ["authorisation_id"], name: "index_violations_on_authorisation"
    t.index ["authorisation_id"], name: "index_violations_on_authorisation_id"
    t.index ["customer_id"], name: "index_violations_on_customer_id"
    t.index ["merchant_id"], name: "index_violations_on_merchant_id"
    t.index ["rule_id"], name: "index_violations_on_rule_id"
    t.index ["violatable_id", "violatable_type"], name: "index_violations_on_violatable_id_and_violatable_type"
    t.index ["violatable_type", "violatable_id"], name: "index_violations_on_violatable"
  end

  create_table "violations_archive", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "internal_code"
    t.integer "rule_priority"
    t.datetime "alert_created_at", null: false
    t.datetime "authorisation_created_at", null: false
    t.bigint "alert_id"
    t.bigint "rule_id"
    t.bigint "account_id"
    t.bigint "authorisation_id"
    t.bigint "customer_id"
    t.string "violatable_type"
    t.bigint "violatable_id"
    t.bigint "merchant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "card_id"
    t.index ["account_id"], name: "index_violations_archive_on_account_id"
    t.index ["alert_id"], name: "index_violations_archive_on_alert_id"
    t.index ["authorisation_id"], name: "index_violations_archive_on_authorisation_id"
    t.index ["card_id"], name: "index_violations_archive_on_card_id"
    t.index ["customer_id"], name: "index_violations_archive_on_customer_id"
    t.index ["merchant_id"], name: "index_violations_archive_on_merchant_id"
    t.index ["rule_id"], name: "index_violations_archive_on_rule_id"
    t.index ["violatable_type", "violatable_id"], name: "index_violations_archive_on_violatable"
  end

  create_table "violations_archive_out", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "internal_code"
    t.integer "rule_priority"
    t.datetime "alert_created_at", null: false
    t.datetime "authorisation_created_at", null: false
    t.bigint "alert_id"
    t.bigint "rule_id"
    t.bigint "account_id"
    t.bigint "authorisation_id"
    t.bigint "customer_id"
    t.string "violatable_type"
    t.bigint "violatable_id"
    t.bigint "merchant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "card_id"
    t.index ["account_id"], name: "index_violations_archive_out_on_account_id"
    t.index ["alert_id"], name: "index_violations_archive_out_on_alert_id"
    t.index ["authorisation_id"], name: "index_violations_archive_out_on_authorisation_id"
    t.index ["card_id"], name: "index_violations_archive_out_on_card_id"
    t.index ["customer_id"], name: "index_violations_archive_out_on_customer_id"
    t.index ["merchant_id"], name: "index_violations_archive_out_on_merchant_id"
    t.index ["rule_id"], name: "index_violations_archive_out_on_rule_id"
    t.index ["violatable_type", "violatable_id"], name: "index_violations_archive_out_on_violatable"
  end

  create_table "violations_out", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "internal_code"
    t.integer "rule_priority"
    t.datetime "alert_created_at", null: false
    t.datetime "authorisation_created_at", null: false
    t.bigint "alert_id"
    t.bigint "rule_id"
    t.bigint "account_id"
    t.bigint "authorisation_id"
    t.bigint "customer_id"
    t.string "violatable_type"
    t.bigint "violatable_id"
    t.bigint "merchant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_violations_out_on_account_id"
    t.index ["alert_id"], name: "index_violations_out_on_alert_id"
    t.index ["authorisation_id"], name: "index_violations_out_on_authorisation"
    t.index ["authorisation_id"], name: "index_violations_out_on_authorisation_id"
    t.index ["customer_id"], name: "index_violations_out_on_customer_id"
    t.index ["merchant_id"], name: "index_violations_out_on_merchant_id"
    t.index ["rule_id"], name: "index_violations_out_on_rule_id"
    t.index ["violatable_id", "violatable_type"], name: "index_violations_out_on_violatable_id_and_violatable_type"
    t.index ["violatable_type", "violatable_id"], name: "index_violations_out_on_violatable"
  end

  create_table "week_days", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "accounts", "cards"
  add_foreign_key "accounts", "members"
  add_foreign_key "accounts", "merchants"
  add_foreign_key "cards", "clients"
end
