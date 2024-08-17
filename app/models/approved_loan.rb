class ApprovedLoan < ApplicationRecord
  belongs_to :loan_request
  belongs_to :user, class_name: 'User', foreign_key: :approved_by
  validates :amount, :interest_rate, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :open, -> { where(is_closed: false) }
end
