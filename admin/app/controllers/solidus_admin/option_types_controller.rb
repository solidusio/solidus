# frozen_string_literal: true

module SolidusAdmin
  class OptionTypesController < SolidusAdmin::BaseController
    before_action :load_option_type, only: [:move]

    def move
      @option_type.insert_at(params[:position].to_i)

      respond_to do |format|
        format.js { head :no_content }
      end
    end

    def destroy
      @option_types = Spree::OptionType.where(id: params[:id])

      Spree::OptionType.transaction { @option_types.destroy_all }

      flash[:notice] = t('.success')
      redirect_back_or_to option_types_path, status: :see_other
    end

    private

    def load_option_type
      @option_type = Spree::OptionType.find(params[:id])
      authorize! action_name, @option_type
    end
  end
end
