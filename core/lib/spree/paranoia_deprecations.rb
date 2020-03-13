# frozen_string_literal: true

module Spree
  module ParanoiaDeprecations
    module InstanceMethods
      def paranoia_destroy
        Spree::Deprecation.warn <<~WARN, caller
          Calling #destroy (or #paranoia_destroy) on a #{self.class} currently performs a soft-destroy using the paranoia gem.
          In Solidus 3.0, paranoia will be removed, and this will perform a HARD destroy instead. To continue soft-deleting, use #discard instead.
        WARN
        super
      end

      def paranoia_delete
        Spree::Deprecation.warn <<~WARN, caller
          Calling #delete (or #paranoia_delete) on a #{self.class} currently performs a soft-destroy using the paranoia gem.
          In Solidus 3.0, paranoia will be removed, and this will perform a HARD destroy instead. To continue soft-deleting, use #discard instead.
        WARN
        super
      end
    end

    module ClassMethods
      def with_deleted
        Spree::Deprecation.warn <<~WARN, caller
          #{self}.with_deleted has been deprecated. Use #{self}.with_discarded instead.
          In Solidus 3.0, paranoia will be removed, and this method will be replaced by #{self}.with_discarded.
        WARN
        super
      end

      def only_deleted
        Spree::Deprecation.warn <<~WARN, caller
          #{self}.only_deleted has been deprecated. Use #{self}.discarded instead.
          In Solidus 3.0, paranoia will be removed, and this method will be replaced by #{self}.discarded.
        WARN
        super
      end
    end
  end
end
