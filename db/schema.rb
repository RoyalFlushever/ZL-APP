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

ActiveRecord::Schema.define(version: 20180226102014) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "apicredetials", force: :cascade do |t|
    t.string "access_key"
    t.string "secret_key"
    t.string "associate_tag"
    t.boolean "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "apikeys", force: :cascade do |t|
    t.string "access_key"
    t.string "secret_key"
    t.boolean "assigned"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "manager"
    t.string "status"
    t.integer "terms"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "inventories", force: :cascade do |t|
    t.string "name"
    t.string "listingID"
    t.string "sellerSku"
    t.decimal "price"
    t.integer "quantity"
    t.datetime "opendate"
    t.string "imageUrl"
    t.string "isMarketplace"
    t.string "asin1"
    t.string "asin2"
    t.string "asin3"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asin1"], name: "index_inventories_on_asin1"
    t.index ["listingID"], name: "index_inventories_on_listingID", unique: true
    t.index ["sellerSku"], name: "index_inventories_on_sellerSku", unique: true
  end

  create_table "progressbars", force: :cascade do |t|
    t.string "taskname"
    t.integer "percent"
    t.string "message"
    t.integer "status"
    t.decimal "tradein"
    t.decimal "buyback"
    t.decimal "profit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["taskname"], name: "index_progressbars_on_taskname", unique: true
  end

end
