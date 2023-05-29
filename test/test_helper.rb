# frozen_string_literal: true

require "minitest/autorun"
require "active_record"
require "active_support"
require "pry"
require_relative "../lib/fast_page"

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:"
)

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, force: true do |t|
    t.string :login
    t.timestamps
    t.index ["login"], unique: true
  end

  create_table :user_organizations, force: true do |t|
    t.integer :user_id
    t.integer :organization_id
    t.timestamps
  end

  create_table :organizations, force: true do |t|
    t.string :name
    t.timestamps
  end
end

class Organization < ActiveRecord::Base
end

class User < ActiveRecord::Base
  has_and_belongs_to_many :organizations, join_table: "user_organizations"
end
