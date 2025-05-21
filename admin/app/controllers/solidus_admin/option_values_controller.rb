# frozen_string_literal: true

module SolidusAdmin
  class OptionValuesController < SolidusAdmin::ResourcesController
    before_action :load_option_value, only: [:move]

    def move
      @option_value.insert_at(params[:position].to_i)

      respond_to do |format|
        format.js { head :no_content }
      end
    end

    private

    def resource_class = Spree::OptionValue

    def load_option_value
      @option_value = Spree::OptionValue.find(params[:id])
      authorize! action_name, @option_value
    end
  end
end
