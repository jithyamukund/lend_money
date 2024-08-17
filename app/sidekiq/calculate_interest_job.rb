class CalculateInterestJob
  include Sidekiq::Job

  def perform
    Rails.logger.info "Starting CalculateInterestJob at #{Time.current}"

    open_loans = LoanRequest.open
    interest_amount = 0
    open_loans.each do |loan|
      approved_loan = loan.approved_loan
      if approved_loan
        interest = calculate_interest(approved_loan)
        approved_loan.update!(interest_amount: interest)
      end
    end

    Rails.logger.info "Finished CalculateInterestJob at #{Time.current}"
  rescue => e
    Rails.logger.error "Error in CalculateInterestJob: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end

  def calculate_interest(approved_loan)
    Rails.logger.info "Calculating interest for loan request ID #{approved_loan.loan_request_id}"

    principal = approved_loan.amount
    rate_of_interest = approved_loan.interest_rate
    time_difference_in_minutes = ((Time.current - approved_loan.created_at) / 60.0).to_f
    interest_amount = principal * (rate_of_interest/100.0)*time_difference_in_minutes/(60*24*365)
    interest_amount.round(2)
  end
end
