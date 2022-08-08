# frozen_string_literal: true

require "active_support/lazy_load_hooks"
require_relative "fast_page/version"
require_relative "fast_page/active_record_extension"

ActiveSupport.on_load :active_record do
  # ActiveRecord::QueryLogs.include(ActiveRecord::SqlCommenter::QueryLogsTagsFormat)
  ::ActiveRecord::Base.include FastPage::ActiveRecordExtension
end

module FastPage
  class Error < StandardError; end
  # Your code goes here...
end
