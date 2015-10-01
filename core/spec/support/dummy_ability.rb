class DummyAbility
  include CanCan::Ability

  attr_reader :user

  def initialize(current_user = nil)
    @user = current_user || Spree.user_class.new
  end
end

