# frozen_string_literal: true

module Solidus
  module NamespaceMigration
    module MailerViewPaths
      module Extension
        def controller_path
          path = super
          path = path.sub('solidus/', 'spree/') if path.start_with?('solidus/')
          path
        end

        def collect_responses_from_templates(headers)
          super(headers.reverse_merge(
            template_path: self.class.mailer_name.sub('solidus/', 'spree/')
          ))
        end
      end

      class << self
        def activate
          affected_modules.each do |affected_module|
            affected_module.prepend Extension
          end
        end

        private

        def affected_modules
          [
            Solidus::BaseMailer
          ].compact.freeze
        end
      end
    end
  end
end
