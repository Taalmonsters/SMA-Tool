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

ActiveRecord::Schema.define(version: 20160227164116) do

  create_table "facebook_searches", force: :cascade do |t|
    t.string   "query"
    t.integer  "status"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "facebook_searches", ["user_id"], name: "index_facebook_searches_on_user_id"

  create_table "facebook_searches_statuses", id: false, force: :cascade do |t|
    t.integer "facebook_status_id", null: false
    t.integer "facebook_search_id", null: false
  end

  create_table "facebook_statuses", force: :cascade do |t|
    t.string   "id_str"
    t.string   "text"
    t.string   "user_screen_name"
    t.string   "user_location"
    t.integer  "share_count"
    t.integer  "like_count"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "hashtags", force: :cascade do |t|
    t.string   "tag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hashtags_tweets", id: false, force: :cascade do |t|
    t.integer "tweet_id",   null: false
    t.integer "hashtag_id", null: false
  end

  create_table "tweets", force: :cascade do |t|
    t.string   "id_str"
    t.string   "text"
    t.string   "lang"
    t.string   "in_reply_to_status_id_str"
    t.string   "user_screen_name"
    t.string   "user_location"
    t.integer  "retweet_count"
    t.integer  "favorite_count"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "tweets_twitter_id_searches", id: false, force: :cascade do |t|
    t.integer "tweet_id",             null: false
    t.integer "twitter_id_search_id", null: false
  end

  create_table "tweets_twitter_searches", id: false, force: :cascade do |t|
    t.integer "tweet_id",          null: false
    t.integer "twitter_search_id", null: false
  end

  create_table "tweets_twitter_streams", id: false, force: :cascade do |t|
    t.integer "tweet_id",          null: false
    t.integer "twitter_stream_id", null: false
  end

  create_table "twitter_auths", force: :cascade do |t|
    t.string   "consumer_key"
    t.string   "consumer_secret"
    t.string   "access_token"
    t.string   "access_secret"
    t.integer  "user_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "twitter_auths", ["user_id"], name: "index_twitter_auths_on_user_id"

  create_table "twitter_id_searches", force: :cascade do |t|
    t.text     "query"
    t.integer  "status"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "twitter_id_searches", ["user_id"], name: "index_twitter_id_searches_on_user_id"

  create_table "twitter_searches", force: :cascade do |t|
    t.string   "query"
    t.integer  "status"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "twitter_searches", ["user_id"], name: "index_twitter_searches_on_user_id"

  create_table "twitter_streams", force: :cascade do |t|
    t.string   "query"
    t.integer  "period"
    t.integer  "status"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "twitter_streams", ["user_id"], name: "index_twitter_streams_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "provider"
    t.string   "uid"
    t.string   "email"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "role"
    t.string   "oauth_token"
    t.time     "oauth_expires_at"
  end

end
