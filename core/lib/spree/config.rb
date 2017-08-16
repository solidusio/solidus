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
      Spree::Config.instance.send(method, *args, &block)
    end
  end
end
