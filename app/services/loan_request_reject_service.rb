class LoanRequestRejectService
  def initialize(loan_request, current_user, note)
    @loan_request = loan_request
    @current_user = current_user
    @note = note
  end

  def reject
    return false unless ['requested', 'readjustment_requested'].include? @loan_request.status

    LoanRequest.transaction do
      last_adjustment = @loan_request.loan_request_logs.where(status: ['requested', 'readjustment_requested']).order(created_at: :asc).last

      if last_adjustment
        if @loan_request.update(status: 'rejected')
          adjustment = @loan_request.loan_request_logs.create(
            amount: last_adjustment.amount,
            interest_rate: last_adjustment.interest_rate,
            user: @current_user,
            status: 'rejected',
            note: @note
          )

          if adjustment.persisted?
            return true
          else
            raise ActiveRecord::Rollback, "Something went wrong!"
          end
        else
          raise ActiveRecord::Rollback, "Failed to update loan request status"
        end
      else
        return false
      end
    end
  end
end
