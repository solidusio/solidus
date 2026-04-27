module SolidusStarterFrontend
  module System
    module CheckoutHelpers
      def setup_custom_products
        create(:store)

        categories = create(:taxonomy, name: 'Categories')
        categories_root = categories.root
        clothing_taxon = create(:taxon, name: 'Clothing', parent_id: categories_root.id, taxonomy: categories)
        accessories_taxon = create(:taxon, name: 'Accessories', parent_id: categories_root.id, taxonomy: categories)
        stickers_taxon = create(:taxon, name: 'Stickers', parent_id: categories_root.id, taxonomy: categories)
        image = create(:image)
        variant = create(:variant, images: [image, image])

        create(:custom_product, name: 'Solidus hoodie', price: '29.99', taxons: [clothing_taxon], variants: [variant])
        create(:custom_product, name: 'Solidus Water Bottle', price: '19.99', taxons: [accessories_taxon])
        create(:custom_product, name: 'Solidus tote', price: '19.99', taxons: [clothing_taxon])
        create(:custom_product, name: 'Solidus mug set', price: '19.99', taxons: [accessories_taxon])
        create(:custom_product, name: 'Solidus winter hat', price: '22.99', taxons: [clothing_taxon])
        create(:custom_product, name: 'Solidus circle sticker', price: '5.99', taxons: [stickers_taxon])
        create(:custom_product, name: 'Solidus notebook', price: '26.99', taxons: [accessories_taxon])
        create(:custom_product, name: 'Solidus t-shirt', price: '9.99', taxons: [clothing_taxon])
        create(:custom_product, name: 'Solidus long sleeve tee', price: '15.99', taxons: [clothing_taxon])
        create(:custom_product, name: 'Solidus dark tee', price: '15.99', taxons: [clothing_taxon])
        create(:custom_product, name: 'Solidus canvas tote bag', price: '15.99', taxons: [accessories_taxon])
        create(:custom_product, name: 'Solidus cap', price: '24.00', taxons: [clothing_taxon])
      end

      #
      # Authentication
      #
      def checkout_as_guest
        click_button "Checkout"

        within '#guest_checkout' do
          fill_in 'Email', with: 'test@example.com'
        end

        click_on 'Continue'
      end

      #
      # Address
      #
      def fill_addresses_fields_with(address)
        fields = %w[
          address1
          city
          zipcode
          phone
        ]
        fields += if SolidusSupport.combined_first_and_last_name_in_address?
          %w[name]
        else
          %w[firstname lastname]
        end

        wait_time = 3
        while wait_time > 0
          fields.each do |field|
            fill_in "order_bill_address_attributes_#{field}", with: address.send(field).to_s
          end
          select "United States of America", from: "order_bill_address_attributes_country_id"
          select address.state.name.to_s, from: "order_bill_address_attributes_state_id"

          break if find("#order_bill_address_attributes_#{fields.first}").value == address.send(fields.first).to_s

          sleep 0.1
          wait_time -= 0.1
        end

        check 'order_use_billing'
      end

      #
      # Payment
      #
      def find_existing_payment_radio(wallet_source_id)
        find("[name='order[wallet_payment_source_id]'][value='#{wallet_source_id}']")
      end

      def find_payment_radio(payment_method_id)
        find("[name='order[payments_attributes][][payment_method_id]'][value='#{payment_method_id}']")
      end

      def find_payment_fieldset(payment_method_id)
        find("fieldset[name='payment-method-#{payment_method_id}']")
      end
    end
  end
end
