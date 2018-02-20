# frozen_string_literal: true

module Spree
  module ParanoiaDeprecations
    def paranoia_destroy
      Spree::Deprecation.warn <<-WARN.strip_heredoc, caller
        Calling #destroy (or #paranoia_destroy) on a #{self.class} currently performs a soft-destroy using the paranoia gem.
        In Solidus 3.0, paranoia will be removed, and this will perform a HARD destroy instead. To continue soft-deleting, use #discard instead.
      WARN
      super
    end

    def paranoia_delete
      Spree::Deprecation.warn <<-WARN.strip_heredoc, caller
        Calling #delete (or #paranoia_delete) on a #{self.class} currently performs a soft-destroy using the paranoia gem.
        In Solidus 3.0, paranoia will be removed, and this will perform a HARD destroy instead. To continue soft-deleting, use #discard instead.
      WARN
      super
    end
  end
end
