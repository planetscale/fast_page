# frozen_string_literal: true

require_relative "test_helper"
require "pry"

require "kaminari"

class KaminariTest < Minitest::Test
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

  def test_kaminari_works
    og_page = User.page(2).per(1).order(created_at: :desc)
    fast_page = User.page(2).per(1).order(created_at: :desc).fast_page

    assert_equal og_page.length, fast_page.length
    assert_equal og_page.first.id, fast_page.first.id
    assert_equal og_page.current_page, fast_page.current_page
    assert_equal og_page.next_page, fast_page.next_page
    assert_equal og_page.prev_page, fast_page.prev_page
  end

  def test_kaminari_works_without_count
    og_page = User.page(2).per(1).order(created_at: :desc).without_count
    fast_page = User.page(2).per(1).order(created_at: :desc).without_count.fast_page

    assert_equal og_page.length, fast_page.length
    assert_equal og_page.first.id, fast_page.first.id
    assert_equal og_page.current_page, fast_page.current_page
    assert_equal og_page.next_page, fast_page.next_page
    assert_equal og_page.prev_page, fast_page.prev_page
  end
end
