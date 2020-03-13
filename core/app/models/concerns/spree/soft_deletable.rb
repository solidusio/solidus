# frozen_string_literal: true

require 'discard'

module Spree
  module SoftDeletable
    extend ActiveSupport::Concern

    included do
      acts_as_paranoid
      include Spree::ParanoiaDeprecations::InstanceMethods
      extend Spree::ParanoiaDeprecations::ClassMethods

      include Discard::Model
      self.discard_column = :deleted_at
    end
  end
end
