Spree::Core::Engine.config.to_prepare do
  if Spree.user_class
    Spree.user_class.class_eval do

      include Spree::UserApiAuthentication
      include Spree::UserReporting

      has_many :role_users, foreign_key: "user_id", class_name: "Spree::RoleUser"
      has_many :spree_roles, through: :role_users, source: :role

      has_many :user_stock_locations, foreign_key: "user_id", class_name: "Spree::UserStockLocation"
      has_many :stock_locations, through: :user_stock_locations

      has_many :spree_orders, foreign_key: "user_id", class_name: "Spree::Order"

      has_many :store_credits, -> { includes(:credit_type) }, foreign_key: "user_id", class_name: "Spree::StoreCredit"
      has_many :store_credit_events, through: :store_credits

      belongs_to :ship_address, class_name: 'Spree::Address'
      belongs_to :bill_address, class_name: 'Spree::Address'

      # has_spree_role? simply needs to return true or false whether a user has a role or not.
      def has_spree_role?(role_in_question)
        spree_roles.any? { |role| role.name == role_in_question.to_s }
      end

      # @return [Spree::Order] the most-recently-created incomplete order
      # since the customer's last complete order.
      def last_incomplete_spree_order(store: nil)
        self_orders = self.orders
        self_orders = self_orders.where(store: store) if store
        last_order = self_orders.order(:created_at).last
        last_order unless last_order.try!(:completed?)
      end

      def total_available_store_credit
        store_credits.reload.to_a.sum{ |credit| credit.amount_remaining }
      end
    end
  end
end
