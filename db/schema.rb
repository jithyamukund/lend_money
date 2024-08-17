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

ActiveRecord::Schema[7.1].define(version: 2024_08_16_173917) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "approved_loans", force: :cascade do |t|
    t.bigint "loan_request_id", null: false
    t.decimal "amount", null: false
    t.decimal "interest_rate", null: false
    t.integer "approved_by", null: false
    t.decimal "interest_amount", default: "0.0", null: false
    t.boolean "is_closed", default: false
    t.decimal "closed_amount"
    t.datetime "closed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approved_by"], name: "index_approved_loans_on_approved_by"
    t.index ["loan_request_id"], name: "index_approved_loans_on_loan_request_id"
  end

  create_table "loan_request_logs", force: :cascade do |t|
    t.bigint "loan_request_id", null: false
    t.decimal "amount", null: false
    t.decimal "interest_rate", null: false
    t.bigint "user_id", null: false
    t.integer "status", null: false
    t.string "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["loan_request_id"], name: "index_loan_request_logs_on_loan_request_id"
    t.index ["user_id"], name: "index_loan_request_logs_on_user_id"
  end

  create_table "loan_requests", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.decimal "amount", null: false
    t.decimal "interest_rate", null: false
    t.integer "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_loan_requests_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.integer "role", null: false
    t.boolean "is_deleted", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "wallets", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.decimal "balance", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_wallets_on_user_id"
  end

  add_foreign_key "approved_loans", "loan_requests"
  add_foreign_key "approved_loans", "users", column: "approved_by"
  add_foreign_key "loan_request_logs", "loan_requests"
  add_foreign_key "loan_request_logs", "users"
  add_foreign_key "loan_requests", "users"
  add_foreign_key "wallets", "users"
end
