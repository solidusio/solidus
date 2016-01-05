module Spree
  module OrderedPropertyValueList
    extend ActiveSupport::Concern

    included do
      acts_as_list

      validates :property, presence: true
      validates_with Spree::Validations::DbMaximumLengthValidator, field: :value

      default_scope -> { order(:position) }

      # virtual attributes for use with AJAX autocompletion
      def property_name
        property.name if property
      end

      def property_name=(name)
        if name.present?
          # don't use `find_by :name` to workaround globalize/globalize#423 bug
          property = Property.where(name: name).first ||
              Property.create(name: name, presentation: name)
          self.property = property
        end
      end
    end
  end
end
