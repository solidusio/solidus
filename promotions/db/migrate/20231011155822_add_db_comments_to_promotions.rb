# frozen_string_literal: true

class AddDbCommentsToPromotions < ActiveRecord::Migration[6.1]
  def up
    if connection.supports_comments?
      change_table_comment(:solidus_promotions_promotions, solidus_promotions_promotions_table_comment)
      change_column_comment(:solidus_promotions_promotions, :id, id_comment)
      change_column_comment(:solidus_promotions_promotions, :description, description_comment)
      change_column_comment(:solidus_promotions_promotions, :expires_at, expires_at_comment)
      change_column_comment(:solidus_promotions_promotions, :starts_at, starts_at_comment)
      change_column_comment(:solidus_promotions_promotions, :customer_label, customer_label_comment)
      change_column_comment(:solidus_promotions_promotions, :usage_limit, usage_limit_comment)
      change_column_comment(:solidus_promotions_promotions, :advertise, advertise_comment)
      change_column_comment(:solidus_promotions_promotions, :path, path_comment)
      change_column_comment(:solidus_promotions_promotions, :lane, lane_comment)
      change_column_comment(:solidus_promotions_promotions, :name, name_comment)
      change_column_comment(:solidus_promotions_promotions, :created_at, created_at_comment)
      change_column_comment(:solidus_promotions_promotions, :updated_at, updated_at_comment)
      change_column_comment(:solidus_promotions_promotions, :promotion_category_id, promotion_category_id_comment)
      change_column_comment(:solidus_promotions_promotions, :per_code_usage_limit, per_code_usage_limit_comment)
      change_column_comment(:solidus_promotions_promotions, :apply_automatically, apply_automatically_comment)
    end
  end

  private

  def solidus_promotions_promotions_table_comment
    <<~COMMENT
      Promotions are sets of rules and actions to discount (parts of) an order.
    COMMENT
  end

  def id_comment
    <<~COMMENT
      Primary key of this table.
    COMMENT
  end

  def description_comment
    <<~COMMENT
      The description of this promotion.
    COMMENT
  end

  def expires_at_comment
    <<~COMMENT
      Timestamp at which the promotion stops being eligible.
    COMMENT
  end

  def starts_at_comment
    <<~COMMENT
      Timestamp at which the promotion starts being eligible.
    COMMENT
  end

  def customer_label_comment
    <<~COMMENT
      The contents of this field will be replicated in the labels of adjustments created with it.
    COMMENT
  end

  def name_comment
    <<~COMMENT
      Admin name of the promotion.
    COMMENT
  end

  def usage_limit_comment
    <<~COMMENT
      How many times this promotion can be applied to orders globally.
    COMMENT
  end

  def advertise_comment
    <<~COMMENT
      Marks a promotion as advertised.
    COMMENT
  end

  def path_comment
    <<~COMMENT
      This could be used for applying a promotion based on a route the customer visits.
    COMMENT
  end

  def lane_comment
    <<~COMMENT
      Priority lane of this promotion.
    COMMENT
  end

  def created_at_comment
    <<~COMMENT
      Timestamp indicating when this record was created.
    COMMENT
  end

  def updated_at_comment
    <<~COMMENT
      Timestamp indicating when this record was last updated.
    COMMENT
  end

  def promotion_category_id_comment
    <<~COMMENT
      Foreign key to the solidus_promotions_promotion_categories table.
    COMMENT
  end

  def per_code_usage_limit_comment
    <<~COMMENT
      How many times this promotion can be used per promotion code.
    COMMENT
  end

  def apply_automatically_comment
    <<~COMMENT
      Whether this promotion applies automatically in the cart, as opposed to the promotion being activated through a promotion code
      or a path (see above).
    COMMENT
  end
end
