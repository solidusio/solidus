module Spree
  class Reimbursement
    module Interactors
      class Performer
        include EventedInteractor

        delegate :reimbursement_tax_calculator, :reload, :calculated_total,
          :update!, :reimbursement_performer, :unpaid_amount_within_tolerance?,
          :reimbursed!, :errored!, :reimbursement_success_hooks, :send_reimbursement_email,
          :reimbursement_failure_hooks, :unpaid_amount, to: :reimbursement

        def call
          unless created_by
            Spree::Deprecation.warn("Calling #perform on #{reimbursement} without created_by is deprecated")
          end
          reimbursement_tax_calculator.call(reimbursement)
          reload
          update!(total: calculated_total)

          reimbursement_performer.perform(reimbursement, created_by: created_by)

          if unpaid_amount_within_tolerance?
            reimbursed!
            reimbursement_success_hooks.each { |h| h.call reimbursement }
            send_reimbursement_email
          else
            errored!
            reimbursement_failure_hooks.each { |h| h.call reimbursement }
            raise IncompleteReimbursementError, I18n.t("spree.validation.unpaid_amount_not_zero", amount: unpaid_amount)
          end
        end

        private

        def reimbursement
          context.reimbursement
        end

        def created_by
          context.created_by
        end
      end
    end
  end
end
