# frozen_string_literal: true

module SolidusAdmin::AdminResources
  def admin_resources(resource, **options)
    batch_actions = %i[destroy]
    batch_actions &= options[:only] if options[:only]
    batch_actions -= options[:except] if options[:except]

    resources(resource, options) do
      yield if block_given?

      collection do
        delete :destroy if batch_actions.include?(:destroy)
      end

      member do
        patch :move if options[:sortable]
      end

      yield if block_given?
    end
  end
end
