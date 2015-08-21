##
# Creates methods on object which delegate to an association proxy.
# see delegate_belongs_to for two uses
#
# Todo - integrate with ActiveRecord::Dirty to make sure changes to delegate object are noticed
# Should do
# class User < Spree::Base; delegate_belongs_to :contact, :firstname; end
# class Contact < Spree::Base; end
# u = User.first
# u.changed? # => false
# u.firstname = 'Bobby'
# u.changed? # => true
#
# Right now the second call to changed? would return false
#
# Todo - add has_one support. fairly straightforward addition
##
module DelegateBelongsTo
  extend ActiveSupport::Concern

  module ClassMethods

    @@default_rejected_delegate_columns = ['created_at','created_on','updated_at','updated_on','lock_version','type','id','position','parent_id','lft','rgt']
    mattr_accessor :default_rejected_delegate_columns

    ##
    # Creates methods for accessing and setting attributes on an association.  Uses same
    # default list of attributes as delegates_to_association.
    # @todo Integrate this with ActiveRecord::Dirty, so if you set a property through one of these setters and then call save on this object, it will save the associated object automatically.
    # delegate_belongs_to :contact
    # delegate_belongs_to :contact, [:defaults]  ## same as above, and useless
    # delegate_belongs_to :contact, [:defaults, :address, :fullname], :class_name => 'VCard'
    ##
    def delegate_belongs_to(association, *attrs)
      opts = attrs.extract_options!
      initialize_association :belongs_to, association, opts
      if attrs.empty? || attrs.delete(:defaults)
        ActiveSupport::Deprecation.warn "delegate_belongs_to with defaults is DEPRECATED. You should specify the attributes you want delegated."
        attrs += get_association_column_names(association)
      end
      attrs.each do |attr|
        define_method attr do |*args|
          send(:delegator_for, association, attr, *args)
        end

        define_method "#{attr}=" do |val|
          send(:delegator_for, association, "#{attr}=", val)
        end
      end
    end

    protected

      def get_association_column_names(association, without_default_rejected_delegate_columns=true)
        begin
          association_klass = reflect_on_association(association).klass
          methods = association_klass.column_names
          methods.reject!{|x|default_rejected_delegate_columns.include?(x.to_s)} if without_default_rejected_delegate_columns
          return methods
        rescue
          return []
        end
      end

      ##
      # initialize_association :belongs_to, :contact
      def initialize_association(type, association, opts={})
        raise 'Illegal or unimplemented association type.' unless [:belongs_to].include?(type.to_s.to_sym)
        if reflect_on_association(association).nil?
          ActiveSupport::Deprecation.warn "delegate_belongs_to was called with an undefined association which is DEPRECATED. You should declare `belongs_to #{association.inspect}` yourself."
          send type, association, opts
        end
      end
  end

  def delegator_for(association, attr, *args)
    send "build_#{association}" if send(association).nil?
    send(association).send(attr, *args)
  end

  protected :delegator_for
end

ActiveRecord::Base.send :include, DelegateBelongsTo
