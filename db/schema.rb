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

ActiveRecord::Schema.define(version: 20150416151105) do

  create_table "profiles", force: :cascade do |t|
    t.string   "phone_number"
    t.boolean  "enrolled_college"
    t.boolean  "us_citizen"
    t.string   "zip_code"
    t.integer  "age"
    t.integer  "people_in_household"
    t.integer  "monthly_income"
    t.boolean  "on_disability"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "active_screener"
    t.string   "food_state"
    t.string   "science_state"
  end

  create_table "snap_eligibilities", force: :cascade do |t|
    t.integer  "snap_dependent_no"
    t.integer  "snap_gross_income"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "snap_eligibility_seniors", force: :cascade do |t|
    t.integer  "snap_dependent_no"
    t.integer  "snap_gross_income"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

end
