# frozen_string_literal: true

require_relative "active_record_methods"

module FastPage
  module ActiveRecordExtension
    extend ActiveSupport::Concern

    included do
      def self.fast_page
        extending do
          include(FastPage::ActiveRecordMethods)
        end.deferred_join_load
      end
    end
  end
end
