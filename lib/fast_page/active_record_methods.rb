# frozen_string_literal: true

module FastPage
  module ActiveRecordMethods
    def deferred_join_load
      # Must have a limit or offset defined
      raise ArgumentError, "You must specify a limit or offset to use fast_page" if !limit_value && !offset_value

      # We load 1 additional record to determine if there is a next page.
      # This helps us avoid doing a count over all records
      @values[:limit] = limit_value + 1 if limit_value
      id_scope = dup
      id_scope = id_scope.except(:includes) unless references_eager_loaded_tables?
      ids = id_scope.pluck(:id).to_set

      if limit_value
        @values[:limit] = limit_value - 1
        # Record if there is a next page
        @_has_next = ids.length > limit_value
        ids = ids.first(limit_value)
      end

      if ids.empty?
        @records = []
        @loaded = true
        return self
      end

      @records = where(id: ids).unscope(:limit).unscope(:offset).load.records
      @loaded = true

      self
    end
  end
end
