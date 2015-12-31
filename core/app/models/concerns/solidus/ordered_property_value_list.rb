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
        unless name.blank?
          unless property = Property.find_by(name: name)
            property = Property.create(name: name, presentation: name)
          end
          self.property = property
        end
      end
    end
  end
end
