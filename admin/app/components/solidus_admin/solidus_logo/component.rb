# frozen_string_literal: true

module SolidusAdmin
  # Renders the solidus logo component
  class SolidusLogo::Component < BaseComponent
    def initialize(logo_path: SolidusAdmin::Config.logo_path)
      @logo_path = logo_path
    end

    erb_template <<~ERB
      <%= image_tag @logo_path, alt: "Solidus" %>
    ERB
  end
end
