class RenameLoanAdjustmentToLoanRequestLog < ActiveRecord::Migration[7.1]
  def change
    rename_table :loan_adjustments, :loan_request_logs
  end
end
