# frozen_string_literal: true

module AwesomeNestedSetOvveride
  # Add :polimorphic key option only when used to make it work with Rails 6.1+,
  # required since rails/rails@2c008d9
  # This can be removed when upgrading to an awesome_nested_set version
  # compliant with Rails 6.1+, already addressed in
  # collectiveidea/awesome_nested_set#421
  module RelateParent
    def acts_as_nested_set_relate_parent!
      # Disable Rubocop to keep original code for diffs
      # rubocop:disable
      options = {
        :class_name => self.base_class.to_s,
        :foreign_key => parent_column_name,
        :primary_key => primary_column_name,
        :counter_cache => acts_as_nested_set_options[:counter_cache],
        :inverse_of => (:children unless acts_as_nested_set_options[:polymorphic]),
        :touch => acts_as_nested_set_options[:touch]
      }
      options[:polymorphic] = true if acts_as_nested_set_options[:polymorphic]
      options[:optional] = true if ActiveRecord::VERSION::MAJOR >= 5
      belongs_to :parent, options
      # rubocop:enable
    end

    CollectiveIdea::Acts::NestedSet.prepend self
  end

  # Skip breaking model reload before update depth. Already addressed in
  # collectiveidea/awesome_nested_set#413
  # This can be removed when a new version of awesome_nested_set is released.
  module Model
    def set_depth!
      return unless has_depth_column?

      in_tenacious_transaction do
        update_depth(level)
      end
    end

    CollectiveIdea::Acts::NestedSet::Model.prepend self
  end
end
