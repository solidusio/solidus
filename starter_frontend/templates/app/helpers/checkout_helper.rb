# frozen_string_literal: true

module CheckoutHelper
  def partial_name_with_fallback(prefix, partial_name, fallback_name = 'default')
    if lookup_context.find_all("#{prefix}/_#{partial_name}").any?
      "#{prefix}/#{partial_name}"
    else
      "#{prefix}/#{fallback_name}"
    end
  end
end
