module Spree
  def self.solidus_version
    "2.5.2"
  end

  def self.solidus_gem_version
    Gem::Version.new(solidus_version)
  end
end
