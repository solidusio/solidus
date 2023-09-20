# frozen_string_literal: true

module SolidusAdmin::ControllerHelpers::Authorization
  extend ActiveSupport::Concern

  included do
    before_action :authorize_solidus_admin_user!
  end

  private

  def current_ability
    @current_ability ||= Spree::Ability.new(current_solidus_admin_user)
  end

  def authorize_solidus_admin_user!
    subject = authorization_subject

    authorize! :admin, subject
    authorize! action_name, subject
  end

  def authorization_subject
    "Spree::#{controller_name.classify}".constantize
  rescue NameError
    raise NotImplementedError, "Couldn't infer the model class from the controller name, " \
      "please implement `#{self.class}#authorization_subject`."
  end
end
