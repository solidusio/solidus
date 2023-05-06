class SolidusAdmin::RolesController < SolidusAdmin::BaseController
  def index
    @roles = Spree::Role.all
  end

  def show
    @role = Spree::Role.find(params[:id])
  end

  def new
    @role = Spree::Role.new
  end

  def create
    @role = Spree::Role.new(role_params)
    if @role.save
      redirect_to admin_roles_path, notice: t('spree.role_successfully_created')
    else
      render action: 'new'
    end
  end

  def edit
    @role = Spree::Role.find(params[:id])
  end

  def update
    @role = Spree::Role.find(params[:id])
    if @role.update_attributes(role_params)
      redirect_to admin_roles_path, notice: t('spree.role_successfully_updated')
    else
      render action: 'edit'
    end
  end

  private
  
  def role_params
    params.require(:role).permit(:name, permission_sets: [])
  end
end
