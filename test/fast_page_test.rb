# frozen_string_literal: true

require_relative "test_helper"

class FastPageTest < Minitest::Test
  def setup
    User.delete_all
    Organization.delete_all

    organizations = [
      Organization.create(name: "planetscale"),
      Organization.create(name: "github")
    ]
    User.create(login: "mikeissocool", organizations: [organizations[0], organizations[1]])
    User.create(login: "iheanyi", organizations: [organizations[0], organizations[1]])
    User.create(login: "nicknicknick", organizations: [organizations[0]])
    User.create(login: "frances", organizations: [organizations[1]])
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

    User.all.includes(:organizations).limit(50).fast_page

    assert_equal 4, queries.size

    # Organizations are not included on the ID query (not needed)
    assert_includes queries, 'SELECT "users"."id" FROM "users" LIMIT ?'
    assert_includes queries, 'SELECT "users".* FROM "users" WHERE "users"."id" IN (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)'
    # Includes are still loaded
    assert_includes queries, 'SELECT "user_organizations".* FROM "user_organizations" WHERE "user_organizations"."user_id" IN (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)'
    assert_includes queries, 'SELECT "organizations".* FROM "organizations" WHERE "organizations"."id" IN (?, ?)'

    ActiveSupport::Notifications.unsubscribe("sql.active_record")
  end

  def test_returns_same_results
    og = User.all.limit(5).offset(5).order(created_at: :desc)
    fast = User.all.limit(5).offset(5).order(created_at: :desc).fast_page

    assert_equal og.length, fast.length
    assert_equal og.select(&:id), fast.select(&:id)
  end

  def test_errors_without_limit_or_offset
    assert_raises(ArgumentError) do
      User.all.fast_page
    end
  end

  def test_works_limit_only
    og = User.all.limit(5).order(created_at: :desc)
    fast = User.all.limit(5).order(created_at: :desc).fast_page

    assert_equal og.length, fast.length
    assert_equal og.select(&:id), fast.select(&:id)
  end

  def test_works_offset_only
    og = User.all.offset(5).order(created_at: :desc)
    fast = User.all.offset(5).order(created_at: :desc).fast_page

    assert_equal og, fast
  end

  def test_to_a_returns_an_array
    assert_equal Array, User.all.limit(5).fast_page.to_a.class
  end

  def test_returns_unique_records_when_including_associations
    og = User.includes(:organizations).where(organizations: { id: Organization.pluck(:id) }).limit(2).order(created_at: :asc)
    fast = User.includes(:organizations).where(organizations: { id: Organization.pluck(:id) }).limit(2).order(created_at: :asc).fast_page

    assert_equal og.length, fast.length
    assert_equal og.select(&:id), fast.select(&:id)
  end
end
