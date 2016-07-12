module Spree
  module Admin
    module ReportsHelper
      def render_field(value)
        if value.is_a?(Array)
          if value.count == 1
            value.first
          else
            content_tag(:ol) do
              value.each do |item|
                content_tag(:li) { item }
              end
            end
          end
        elsif !!value == value # i.e. value is Boolean
          value.to_s.titlecase
        else
          value
        end
      end
    end
  end
end
