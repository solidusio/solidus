module Spree
  module Validations
    ##
    # Validates a field based on the maximum length of the underlying DB field, if there is one.
    class DbMaximumLengthValidator < ActiveModel::Validator
      def initialize(options)
        super
        @field = options[:field].to_s
        raise ArgumentError.new("a field must be specified to the validator") if @field.blank?
      end

      def validate(record)
        field = record.class.columns_hash[@field]
        # solidus_globalize want its translated fields to be removed from the
        # DB. Even if they are kept, they will not appear in `.columns_hash`
        # and friends because they are added to `ignored_columns`.
        return unless field

        limit = field.limit
        value = record[@field.to_sym]
        if value && limit && value.to_s.length > limit
          record.errors.add(@field.to_sym, :too_long, count: limit)
        end
      end
    end
  end
end
