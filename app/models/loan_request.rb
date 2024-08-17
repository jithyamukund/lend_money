class LoanRequest < ApplicationRecord
  belongs_to :user
  has_many :loan_request_logs, dependent: :destroy
  has_one :approved_loan, dependent: :destroy
  validates :amount, :interest_rate, presence: true, numericality: { greater_than_or_equal_to: 0 }

  enum status: {
    requested: 0,
    approved: 1,
    open: 2,
    closed: 3,
    rejected: 4,
    waiting_for_adjustment_acceptance: 5,
    readjustment_requested: 6
  }

  after_initialize :set_status, if: :new_record?
  after_create :create_initial_adjustment

  private

  def set_status
    self.status = 0
  end

  def create_initial_adjustment
    LoanRequestLog.create!(
      loan_request: self,
      amount: amount,
      interest_rate: interest_rate,
      user_id: user_id,
      status: 0,
      note: 'Initial loan request created'
    )
  end

end
