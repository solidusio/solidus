# frozen_string_literal: true

module Spree
  module ActiveStorageAdapter
    # Contains normalization methods to make objects compliant with
    # ActiveStorage API.
    module Normalization
      # Normalizes an attachable
      def normalize_attachable(attachable)
        case attachable
        when ActiveStorage::Blob, ActionDispatch::Http::UploadedFile,
          Rack::Test::UploadedFile, Hash, String
          attachable
        when Attachment, ActiveStorage::Attached
          attachable_blob(attachable)
        else # assume it's an IO
          attachable_io(attachable)
        end
      end

      private

      def attachable_blob(attachable)
        attachable.blob
      end

      def attachable_io(attachable)
        filename = if attachable.respond_to?(:to_path)
                     attachable.to_path
                   else
                     SecureRandom.uuid
                   end
        attachable.rewind

        { io: attachable, filename: filename }
      end
    end
  end
end
