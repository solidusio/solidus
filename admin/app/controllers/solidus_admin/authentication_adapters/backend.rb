# frozen_string_literal: true

module SolidusAdmin::AuthenticationAdapters::Backend
  extend ActiveSupport::Concern

  included do
    delegate :admin_logout_path, to: :spree
    helper_method :admin_logout_path
  end

  private

  def authenticate_solidus_backend_user!
    if respond_to?(:model_class, true) && model_class
      record = model_class
    else
      record = controller_name.to_sym
    end
    authorize! :admin, record
    authorize! action_name.to_sym, record
  rescue CanCan::AccessDenied
    instance_exec(&Spree::Admin::BaseController.unauthorized_redirect)
  end

  # Needs to be overriden so that we use Spree's Ability rather than anyone else's.
  def current_ability
    @current_ability ||= Spree::Ability.new(spree_current_user)
  end

  def store_location
    Spree::UserLastUrlStorer.new(self).store_location
  end

  def spree_current_user
    defined?(super) ? super : nil
  end
end
