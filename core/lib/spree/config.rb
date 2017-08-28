module Spree
  class Config
    def self.instance
      @@instance || Spree::AppConfiguration.new
    end

    def self.instance=(value)
      @@instance = value
    end

    def self.[](index)
      Spree::Config.instance[index]
    end

    def self.[]=(index, value)
      Spree::Config.instance[index] = value
    end

    def self.method_missing(method, *args, &block)
      if Spree::Config.instance.respond_to?(method, true)
        Spree::Config.instance.send(method, *args, &block)
      else
        super
      end
    end

    def self.respond_to_missing?(method, include_private = true)
      Spree::Config.instance.respond_to?(method, include_private) || super
    end
  end
end
