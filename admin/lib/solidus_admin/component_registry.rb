# frozen_string_literal: true

module SolidusAdmin
  class ComponentRegistry
    ComponentNotFoundError = Class.new(NameError)

    def initialize
      @names = {}
    end

    delegate :[]=, to: :@names

    def [](key)
      if @names[key]
        @names[key].constantize
      else
        infer_constant_from(key)
      end
    end

    private

    def infer_constant_from(key)
      "solidus_admin/#{key}/component".classify.constantize
    rescue NameError
      prefix = "#{SolidusAdmin::Configuration::ENGINE_ROOT}/app/components/solidus_admin/"
      suffix = "/component.rb"
      dictionary = Dir["#{prefix}**#{suffix}"].map { _1.delete_prefix(prefix).delete_suffix(suffix) }
      corrections = DidYouMean::SpellChecker.new(dictionary:).correct(key.to_s)

      raise ComponentNotFoundError.new(
        "Unknown component #{key}#{DidYouMean.formatter.message_for(corrections)}",
        key.classify,
        receiver: ::SolidusAdmin
      )
    end
  end
end
