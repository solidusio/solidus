# frozen_string_literal: true

module Spree
  # Adapts ActiveStorage interface to make it compliant with Solidus'
  # Paperclip-oriented attachment support.
  module ActiveStorageAdapter
    extend ActiveSupport::Concern
    include Spree::ActiveStorageAdapter::Normalization

    included do
      next if Rails.gem_version >= Gem::Version.new('6.1.0.alpha')

      abort <<~MESSAGE
        Configuration Error: Solidus ActiveStorage attachment adpater requires Rails >= 6.1.0.

        Spree::Config.image_attachment_module preference is set to #{Spree::Config.image_attachment_module}
        Spree::Config.taxon_attachment_module preference is set to #{Spree::Config.taxon_attachment_module}
        Rails version is #{Rails.gem_version}

        To solve the problem you can upgrade to a Rails version greater than or equal to 6.1.0
        or use legacy Paperclip attachment adapter by editing `config/initialiers/spree/rb`:
        config.image_attachment_module = 'Spree::Image::PaperclipAttachment'
        config.taxon_attachment_module = 'Spree::Taxon::PaperclipAttachment'
      MESSAGE
    end

    class_methods do
      attr_reader :attachment_name
      attr_reader :attachment_definition

      # Specifies the relation between a single attachment and the model
      def has_attachment(name, definition)
        @attachment_name = name.to_sym
        @attachment_definition = definition

        has_one_attached attachment_name

        override_reader
        override_writer
        define_image_validation
        define_presence_reader
      end

      def attachment_definitions
        { attachment_name => attachment_definition }
      end

      private

      def override_reader
        method_name = attachment_name
        override = Module.new do
          define_method method_name do |*args|
            attachment = Attachment.new(super(), styles: styles)
            if args.empty?
              attachment
            else
              style = args.first || default_style
              attachment.url(style)
            end
          end
        end
        prepend override

        alias_method :attachment, method_name if method_name != :attachment
      end

      def override_writer
        method_name = :"#{attachment_name}="
        override = Module.new do
          define_method method_name do |attachable|
            no_other_changes = persisted? && !changed?
            super(normalize_attachable(attachable))
            save if no_other_changes
          end
        end
        prepend override
      end

      def define_image_validation
        define_method :"#{attachment_name}_is_an_image" do
          return unless attachment.attached?
          return if attachment.image?

          errors.add(self.class.attachment_name, 'is not an image')
        end
      end

      def define_presence_reader
        define_method :"#{attachment_name}_present?" do
          attachment.attached?
        end
      end
    end

    def styles
      self.class.attachment_definition[:styles]
    end

    def default_style
      self.class.attachment_definition[:default_style]
    end

    def filename
      attachment.filename
    end

    def url(style = default_style)
      attachment.url(style)
    end

    def destroy_attachment(_name)
      attachment.destroy
    end
  end
end
