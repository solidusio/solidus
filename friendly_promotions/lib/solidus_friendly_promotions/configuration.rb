# frozen_string_literal: true

module SolidusFriendlyPromotions
  class Configuration
    # Define here the settings for this extension, e.g.:
    #
    # attr_accessor :my_setting
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    alias_method :config, :configuration

    def configure
      yield configuration
    end
  end
end
