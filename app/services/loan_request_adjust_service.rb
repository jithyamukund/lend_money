class LoanRequestAdjustService
  def initialize(loan_adjustment, loan_request, current_user)
    @loan_adjustment = loan_adjustment
    @loan_request = loan_request
    @loan_adjustment.user = current_user
  end

  def adjust
    return false unless ['requested', 'readjustment_requested'].include? @loan_request.status

    LoanRequest.transaction do
      @loan_adjustment.status = 'waiting_for_adjustment_acceptance'
      if @loan_adjustment.save
        if @loan_request.update(status: 'waiting_for_adjustment_acceptance')
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
