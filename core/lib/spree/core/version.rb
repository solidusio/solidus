module Spree
  def self.version
    ActiveSupport::Deprecation.warn("Spree.version does not work and will be removed from solidus")
    "2.4.6.beta"
  end
end
