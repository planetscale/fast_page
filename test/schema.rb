# frozen_string_literal: true

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, force: true do |t|
    t.string :login
    t.timestamps
  end
end
