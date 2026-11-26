# frozen_string_literal: true

module SolidusAdmin
  class ProductImagesController < SolidusAdmin::BaseController
    include SolidusAdmin::Moveable

    before_action :load_product
    before_action :load_image, only: [:edit, :update]

    def new
      @image = @product.master.images.new
      render component("products/show/images/new").new(product: @product, image: @image)
    end

    def create
      attachments = (image_params[:attachment] || []).reject(&:blank?)

      if attachments.none?
        render component("products/show").new(product: @product),
          status: :unprocessable_entity
        return
      end

      @images = attachments.map { Spree::Image.new(viewable: @product.master, attachment: _1) }

      if @images.all?(&:save)
        respond_to do |format|
          format.html { redirect_to @product, status: :see_other }
          format.turbo_stream
        end
      else
        flash.now[:error] = build_attachment_error_messages(@images)

        respond_to do |format|
          format.html {
            render component("products/show").new(product: @product),
              status: :unprocessable_entity
          }
          format.turbo_stream {
            render turbo_stream: turbo_stream.replace(
              :new_product_image,
              component("products/show/images/new").new(product: @product, flash:)
            ),
              status: :unprocessable_entity
          }
        end
      end
    end

    def destroy
      images = Spree::Image.where(id: Array.wrap(params[:id]))
      count = images.size
      images.destroy_all

      flash[:notice] = t("solidus_admin.products.images.destroy.success", count:)

      redirect_to @product, status: :see_other
    end

    def edit
      render component("products/show/images/edit").new(product: @product, image: @image)
    end

    def update
      if @image.update(image_params)
        flash[:notice] = t("solidus_admin.products.images.update.success")
        redirect_to @product, status: :see_other
      else
        render component("products/show/images/edit").new(product: @product, image: @image), status: :unprocessable_entity
      end
    end

    private

    def load_product
      @product = Spree::Product.friendly.find(params[:product_id])
    end

    def load_image
      @image = Spree::Image.find(params[:id])
    end

    def image_params
      params.require(:image).permit(:alt, :position, attachment: [])
    end

    def authorization_subject
      Spree::Image
    end

    def moveable_class = Spree::Image

    def build_attachment_error_messages(images)
      @images.filter_map { |image|
        next unless image.errors.any?
        image.errors.full_messages.map { |message| "#{image.filename}: #{message}" }
      }.flatten.join("<br>")
    end
  end
end
