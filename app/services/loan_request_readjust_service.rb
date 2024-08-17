class LoanRequestReadjustService
  def initialize(loan_adjustment, loan_request, current_user)
    @loan_adjustment = loan_adjustment
    @loan_request = loan_request
    @loan_adjustment.user = current_user
  end

  def readjust
    return false unless @loan_request.status == "waiting_for_adjustment_acceptance"

    LoanRequest.transaction do
      @loan_adjustment.status = 'readjustment_requested'
      if @loan_adjustment.save
        if @loan_request.update(status: 'readjustment_requested')
          return true
        else
          raise ActiveRecord::Rollback
        end
      else
        raise ActiveRecord::Rollback
      end
    end
  end
end
