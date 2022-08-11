# frozen_string_literal: true

require "active_support/lazy_load_hooks"
require_relative "fast_page/version"
require_relative "fast_page/active_record_extension"

ActiveSupport.on_load :active_record do
  ::ActiveRecord::Base.include FastPage::ActiveRecordExtension
end
