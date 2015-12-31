module Solidus
  module UserApiAuthentication
    def generate_solidus_api_key!
      generate_solidus_api_key
      save!
    end

    def generate_solidus_api_key
      self.solidus_api_key = SecureRandom.hex(24)
    end

    def clear_solidus_api_key!
      clear_solidus_api_key
      save!
    end

    def clear_solidus_api_key
      self.solidus_api_key = nil
    end
  end
end
