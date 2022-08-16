# frozen_string_literal: true

require_relative "test_helper"
require "pagy"

class PagyTest < Minitest::Test
  include Pagy::Backend

  # Need to override pagy_get_items to use `fast_page`
  def pagy_get_items(collection, pagy)
    collection.offset(pagy.offset).limit(pagy.items).fast_page
  end

  Pagy::DEFAULT[:items] = 5

  def params
    { page: 1, items: 5 }
  end

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

  def test_pagy_works
    queries = []

    ActiveSupport::Notifications.subscribe("sql.active_record") do |sql|
      queries << sql.payload[:sql]
    end

    pagy, records = pagy(User.all)

    assert_equal 5, pagy.items
    assert_equal 1, pagy.page
    assert_equal 2, pagy.next
    assert_equal 5, records.size
    assert_equal 2, queries.size

    assert_includes queries, 'SELECT COUNT(*) FROM "users"'
    assert_includes queries, 'SELECT "users".* FROM "users" WHERE "users"."id" IN (SELECT "users"."id" FROM "users" LIMIT ? OFFSET ?)'

    ActiveSupport::Notifications.unsubscribe("sql.active_record")
  end
end
