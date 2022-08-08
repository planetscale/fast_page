# frozen_string_literal: true

module FastPage
  module ActiveRecordMethods
    def deferred_join_load
      # Must have a limit or offset defined
      raise ArgumentError, "You must specify a limit or offset to use fast_page" if !limit_value && !offset_value

      id_scope = dup
      id_scope = id_scope.except(:includes) unless references_eager_loaded_tables?
      ids = id_scope.pluck(:id)

      if ids.empty?
        @records = []
        @loaded = true
        return self
      end

      @records = where(id: ids).limit(nil).offset(nil).load
      @loaded = true

      self
    end
  end
end
