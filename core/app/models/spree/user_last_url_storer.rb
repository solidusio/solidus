# frozen_string_literal: true

module Spree
  # This service object is responsible for storing the current path into
  # into `session[:spree_user_return_to]` for redirects after successful
  # user/admin authentication.
  class UserLastUrlStorer
    # Lists all the rules that will be evaluated before storing the
    # current path value into the session.
    #
    # @return [Spree::Core::ClassConstantizer::Set] a set of rules
    #  that, when matched, will prevent session[:spree_user_return_to]
    #  to be set
    #
    # @example This method can be used also to add more rules
    #  Spree::UserLastUrlStorer.rules << 'CustomRule'
    #
    # @example it can be used also for removing unwanted rules
    #  Spree::UserLastUrlStorer.rules.delete('CustomRule')
    #
    def self.rules
      Spree::Config.user_last_url_storer_rules
    end

    # @param controller [ApplicationController] an instance of ApplicationController
    #  or its subclasses. The controller will be passed to each rule for matching.
    def initialize(controller)
      @controller = controller
    end

    # Stores into session[:spree_user_return_to] the request full path for
    # future redirects (to be used after successful authentication). When
    # there is a rule match then the request full path is not stored.
    def store_location
      return if self.class.rules.any? { |rule| rule.match? controller }

      session[:spree_user_return_to] = request.fullpath.gsub('//', '/')
    end

    private

    attr_reader :controller

    delegate :session, :request, to: :controller
  end
end
