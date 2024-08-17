class LoanRequestLog < ApplicationRecord
  belongs_to :loan_request
  belongs_to :user

  enum status: {
    requested: 0,
    approved: 1,
    open: 2,
    closed: 3,
    rejected: 4,
    waiting_for_adjustment_acceptance: 5,
    readjustment_requested: 6
  }
end
