# frozen_string_literal: true

module Spree
  module Api
    module TestingSupport
      module Helpers
        def json_response
          case body = JSON.parse(response.body)
          when Hash
            body.with_indifferent_access
          when Array
            body
          end
        end

        def assert_not_found!
          expect(json_response).to eq({"error" => "The resource you were looking for could not be found."})
          expect(response.status).to eq 404
        end

        def assert_unauthorized!
          expect(json_response).to eq({"error" => "You are not authorized to perform that action."})
          expect(response.status).to eq 401
        end

        def stub_authentication!
          allow(Spree.user_class).to receive(:find_by).with(hash_including(:spree_api_key)) { current_api_user }
        end

        # This method can be overridden (with a let block) inside a context
        # For instance, if you wanted to have an admin user instead.
        def current_api_user
          @_current_api_user ||= stub_model(Spree::LegacyUser, email: "solidus@example.com", spree_roles: [])
        end

        def image(filename)
          File.open(
            File.join(
              Spree::Core::Engine.root,
              "lib",
              "spree",
              "testing_support",
              "fixtures",
              filename
            )
          )
        end

        def upload_image(filename)
          Rack::Test::UploadedFile.new(File.open(image(filename).path), "image/jpeg")
        end
      end
    end
  end
end
