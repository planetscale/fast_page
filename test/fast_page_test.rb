# frozen_string_literal: true

require "minitest/autorun"
require "active_record"
require "active_support"

require_relative "../lib/fast_page"

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:"
)

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, force: true do |t|
    t.string :login
    t.integer :organization_id
    t.timestamps
    t.index ["login"], unique: true
  end

  create_table :organizations, force: true do |t|
    t.string :name
    t.timestamps
  end
end

class Organization < ActiveRecord::Base
end

class User < ActiveRecord::Base
  belongs_to :organization
end

class SqlCommenterTest < Minitest::Test
  def setup
    User.delete_all
    Organization.delete_all

    org = Organization.create(name: "planetscale")
    User.create(login: "mikeissocool", organization: org)
    User.create(login: "iheanyi")
    User.create(login: "nicknicknick")
    User.create(login: "frances")
    User.create(login: "phani")
    User.create(login: "jason")
    User.create(login: "derek")
    User.create(login: "dgraham")
    User.create(login: "ayrton")
    User.create(login: "dbussink")
  end

  def test_executes_extra_id_query
    count = 0
    ActiveSupport::Notifications.subscribe("sql.active_record") { count += 1 }

    User.all.limit(5).fast_page

    assert_equal 2, count

    ActiveSupport::Notifications.unsubscribe("sql.active_record")
  end

  def test_correct_sql
    queries = []

    ActiveSupport::Notifications.subscribe("sql.active_record") do |sql|
      queries << sql.payload[:sql]
    end

    User.all.limit(5).fast_page

    assert_equal 2, queries.size
    assert_includes queries, 'SELECT "users"."id" FROM "users" LIMIT ?'
    assert_includes queries, 'SELECT "users".* FROM "users" WHERE "users"."id" IN (?, ?, ?, ?, ?)'

    ActiveSupport::Notifications.unsubscribe("sql.active_record")
  end

  def test_removes_includes_id_query
    queries = []

    ActiveSupport::Notifications.subscribe("sql.active_record") do |sql|
      queries << sql.payload[:sql]
    end

    User.all.includes(:organization).limit(50).fast_page

    assert_equal 3, queries.size

    # Organizations are not included on the ID query (not needed)
    assert_includes queries, 'SELECT "users"."id" FROM "users" LIMIT ?'
    assert_includes queries, 'SELECT "users".* FROM "users" WHERE "users"."id" IN (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)'
    # Includes are still loaded
    assert_includes queries, 'SELECT "organizations".* FROM "organizations" WHERE "organizations"."id" = ?'

    ActiveSupport::Notifications.unsubscribe("sql.active_record")
  end

  def test_returns_same_results
    og = User.all.limit(5).offset(5).order(created_at: :desc)
    fast = User.all.limit(5).offset(5).order(created_at: :desc).fast_page

    assert_equal og, fast
  end

  def test_errors_without_limit_or_offset
    assert_raises(ArgumentError) do
      User.all.fast_page
    end
  end

  def test_works_limit_only
    og = User.all.limit(5).order(created_at: :desc)
    fast = User.all.limit(5).order(created_at: :desc).fast_page

    assert_equal og, fast
  end

  def test_works_offset_only
    og = User.all.offset(5).order(created_at: :desc)
    fast = User.all.offset(5).order(created_at: :desc).fast_page

    assert_equal og, fast
  end
end
