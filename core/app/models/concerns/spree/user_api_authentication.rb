# frozen_string_literal: true

module Spree
  module UserApiAuthentication
    # Generate a json web token
    # @see https://github.com/jwt/ruby-jwt
    # @return [String]
    def generate_jwt_token(options: Spree::Config.jwt_options, expires_in: nil)
      # @see https://github.com/jwt/ruby-jwt#support-for-reserved-claim-names
      extras = {}
      extras['exp'] = Time.current.to_i + expires_in if expires_in.present?
      extras['iat'] = Time.current

      payload = as_json(options)
      payload.merge(extras)

      JWT.encode payload, Spree::Config.jwt_secret, Spree::Config.jwt_algorithm
    end

    def generate_spree_api_key!
      generate_spree_api_key
      save!
    end

    def generate_spree_api_key
      self.spree_api_key = SecureRandom.hex(24)
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
