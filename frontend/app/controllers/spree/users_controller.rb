# frozen_string_literal: true

class Spree::UsersController < Spree::StoreController
  skip_before_action :set_current_order, only: :show, raise: false
  prepend_before_action :load_object, only: :show

  include Spree::Core::ControllerHelpers

  def show
    @orders = @user.orders.complete.order('completed_at desc')
  end

  private

  def load_object
    @user ||= Spree.user_class.find_by(id: try_spree_current_user&.id)
    authorize! params[:action].to_sym, @user
  end

  def accurate_title
    I18n.t('spree.my_account')
  end
end
