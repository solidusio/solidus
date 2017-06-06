module Spree
  module UserApiAuthentication
    def generate_spree_api_key!
      generate_spree_api_key
      save!
    end

    def generate_spree_api_key
      self.spree_api_key = SecureRandom.hex(24)
    end

    def generate_spree_jwt(expires_in)
      payload = self.as_json(only: [:id, :email, :login])
      payload.merge({ exp: Time.now.to_i + expires_in }) if expires_in.present?

      JWT.encode payload, Rails.application.secrets.secret_key_base, 'HS256'
    end

    def clear_spree_api_key!
      clear_spree_api_key
      save!
    end

    def clear_spree_api_key
      self.spree_api_key = nil
    end
  end
end
