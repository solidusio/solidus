# frozen_string_literal: true

module Spree
  module Api
    module Responders
      module JbuilderTemplate
        def to_format
          if template
            render template, status: options[:status] || 200
          else
            super
          end
        end

        def template
          options[:default_template]
        end
      end

      RablTemplate = ActiveSupport::Deprecation::DeprecatedConstantProxy.new('RablTemplate', 'JbuilderTemplate')
    end
  end
end
