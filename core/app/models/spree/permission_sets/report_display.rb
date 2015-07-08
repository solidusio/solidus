module Spree
  module PermissionSets
    class ReportDisplay < PermissionSets::Base
      def activate!
        can [:display, :admin, :sales_total], :reports
      end
    end
  end
end
