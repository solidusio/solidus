# frozen_string_literal: true

module Spree
  module ActiveStorageAdapter
    # Declares Active Storage attachments with the interface of Solidus'
    # Paperclip-oriented attachment support. A model can declare several.
    #
    # Unlike {Spree::ActiveStorageAdapter}, it adds no instance methods named
    # after the attachment itself (such as +url+ or +filename+), so it can be
    # used by models with attributes of those names.
    module HasAttachments
      extend ActiveSupport::Concern
      include Spree::ActiveStorageAdapter::Normalization

      class_methods do
        # @return [Symbol] the name of the first attachment declared
        attr_reader :attachment_name
        # @return [Hash] the definition of the first attachment declared
        attr_reader :attachment_definition

        # Specifies the relation between an attachment and the model
        def has_attachment(name, definition)
          name = name.to_sym
          @attachment_name ||= name
          @attachment_definition ||= definition
          attachment_definitions[name] = definition

          has_one_attached name

          override_reader(name, definition)
          override_writer(name)
          define_image_validation(name)
          define_presence_reader(name)
        end

        def attachment_definitions
          @attachment_definitions ||= {}
        end

        private

        def override_reader(name, definition)
          override = Module.new do
            define_method name do |*args|
              attachment = Attachment.new(super(), styles: definition[:styles] || {})
              if args.empty?
                attachment
              else
                style = args.first || definition[:default_style]
                attachment.url(style)
              end
            end
          end
          prepend override
        end

        def override_writer(name)
          method_name = :"#{name}="
          override = Module.new do
            define_method method_name do |attachable|
              no_other_changes = persisted? && !changed?
              super(normalize_attachable(attachable))
              save if no_other_changes
            end
          end
          prepend override
        end

        def define_image_validation(name)
          define_method :"#{name}_is_an_image" do
            attachment = public_send(name)
            return unless attachment.attached?
            return if attachment.image?

            errors.add(name, "is not an image")
          end
        end

        def define_presence_reader(name)
          define_method :"#{name}_present?" do
            public_send(name).attached?
          end
        end
      end

      # Destroys the named attachment. A name that is not one of the model's
      # attachments falls back to the first one declared, as it did when a
      # model could only have one, so that it is never used to call another
      # method.
      def destroy_attachment(name)
        name = name&.to_sym
        name = self.class.attachment_name unless self.class.attachment_definitions.key?(name)

        public_send(name).destroy
      end
    end
  end
end
