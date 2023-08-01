# frozen_string_literal: true

module SolidusAdmin
  module FeatureHelpers
    def sign_in(user)
      allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(user)
    end
  end
end
