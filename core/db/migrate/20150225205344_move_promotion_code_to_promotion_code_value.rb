class MovePromotionCodeToPromotionCodeValue < ActiveRecord::Migration
  def up

    # This is done via SQL for performance reasons. For larger stores it makes
    # a difference of minutes vs hours for completion time.

    say_with_time 'generating solidus_promotion_codes' do
      Solidus::Promotion.connection.execute(<<-SQL.strip_heredoc)
        insert into solidus_promotion_codes
          (promotion_id, value, created_at, updated_at)
        select
          solidus_promotions.id,
          solidus_promotions.code,
          '#{Time.current.to_s(:db)}',
          '#{Time.current.to_s(:db)}'
        from solidus_promotions
        left join solidus_promotion_codes
          on solidus_promotion_codes.promotion_id = solidus_promotions.id
        where (solidus_promotions.code is not null and solidus_promotions.code <> '') -- promotion has a code
          and solidus_promotion_codes.id is null -- a promotion_code hasn't already been created
      SQL
    end

    if Solidus::PromotionCode.group(:promotion_id).having("count(0) > 1").exists?
      raise "Error: You have promotions with multiple promo codes. The
             migration code will not work correctly".squish
    end

    say_with_time 'linking order promotions' do
      Solidus::Promotion.connection.execute(<<-SQL.strip_heredoc)
        update solidus_orders_promotions
        set promotion_code_id = (
          select solidus_promotion_codes.id
          from solidus_promotions
          inner join solidus_promotion_codes
            on solidus_promotion_codes.promotion_id = solidus_promotions.id
          where solidus_promotions.id = solidus_orders_promotions.promotion_id
        )
        where solidus_orders_promotions.promotion_code_id is null
      SQL
    end

    say_with_time 'linking adjustments' do
      Solidus::Promotion.connection.execute(<<-SQL.strip_heredoc)
        update solidus_adjustments
        set promotion_code_id = (
          select solidus_promotion_codes.id
          from solidus_promotion_actions
          inner join solidus_promotions
            on solidus_promotions.id = solidus_promotion_actions.promotion_id
          inner join solidus_promotion_codes
            on solidus_promotion_codes.promotion_id = solidus_promotions.id
          where solidus_promotion_actions.id = solidus_adjustments.source_id
        )
        where solidus_adjustments.source_type = 'Solidus::PromotionAction'
          and solidus_adjustments.promotion_code_id is null
      SQL
    end
  end

  def down
    # We can't do a down migration because we can't tell which data was created
    # by this migration and which data already existed.
  end
end
